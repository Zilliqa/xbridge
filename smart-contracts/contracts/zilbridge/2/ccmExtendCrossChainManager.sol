// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import { IEthCrossChainManager, IUpgradableECCM, UpgradableECCM, IEthCrossChainData } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { CallingProxy } from "./CallingProxy.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";


// This is a contract which can replace the CCM. It allows the owner to register lock proxy extensions,
// and forwards all other requests to the original cross chain manager.
// see docs/zilbridge.md for details.
// We can't implement IEthCrossChainManager, because we use the fallback for that.
contract EthExtendCrossChainManager is CallingProxy {
  address public originalCCM;
  address public _owner;

  // Why payable? Because that's what the parent CCM does.
  constructor(address _originalCCM) {
    _owner = address(msg.sender);
    originalCCM = _originalCCM;
  }

  function _implementation() internal view override returns (address) {
    return originalCCM;
  }

  function proxyOwner() external view returns (address) {
    return _owner;
  }

  // The upgrade process for the EthCrossChainManager (in ccmproxy::upgradeEthCrossChainManager()) is such that
  // the new CCM gets handed ownership of the cross chain data (ccmCrossChainManager::upgradeToNew()).
  // We don't want it and must therefore arrange to hand it back ..
  function handCrossChainDataBackToImplementation() public {
    require(address(msg.sender) == _owner);
    UpgradableECCM eccm = UpgradableECCM(originalCCM);
    address dataAddress = eccm.EthCrossChainDataAddress();
    IEthCrossChainData eccd = IEthCrossChainData(dataAddress);
    eccd.transferOwnership(originalCCM);
  }

}
