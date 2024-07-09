// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import { Utils, ZeroCopySink, IEthCrossChainManager, IUpgradableECCM,
      UpgradableECCM, IEthCrossChainData, EthCrossChainManager } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { Ownable } from "lib/openzeppelin-contracts/contracts/access/Ownable.sol";



interface ILockProxy {
  function addExtension(
      bytes calldata _argsBz,
      bytes calldata /* _fromContractAddr */,
      uint64 _fromChainId
                        ) external returns (bool);

  function removeExtension(
      bytes calldata _argsBz,
      bytes calldata /* _fromContractAddr */,
      uint64 _fromChainId
                           ) external returns (bool);
}

// This is a contract which can replace the CCM. It allows the owner to register lock proxy extensions,
// and forwards all other requests to the original cross chain manager.
// see docs/zilbridge.md for details.
// We can't implement IEthCrossChainManager, because we use the fallback for that.
contract EthExtendCrossChainManager is EthCrossChainManager {
  address public _extensionManager;
  event ExtensionManagerTransferred(address indexed previousExtender, address indexed newExtender);

  constructor(address _eccd,
              uint64 _chainId,
              address[] memory fromContractWhiteList,
              bytes[] memory contractMethodWhiteList) EthCrossChainManager(_eccd, _chainId, fromContractWhiteList, contractMethodWhiteList)
  {
    _extensionManager = payable(msg.sender);
    emit ExtensionManagerTransferred(address(0), _extensionManager);
  }

  function extensionManager() public view returns (address) { return _extensionManager; }

  function isExtensionManager() public view returns (bool) {
    return payable(msg.sender) == _extensionManager;
  }

  modifier onlyExtensionManager() {
    require(isExtensionManager(), "CCM: Caller is not the extension manager");
    _;
  }

  function transferExtensionManagement(address newManager) public onlyExtensionManager {
    _transferExtensionManagement(newManager);
  }

  function renounceExtensionManagement() public onlyExtensionManager {
    emit ExtensionManagerTransferred(_extensionManager, address(0));
    _extensionManager = address(0);
  }

  function _transferExtensionManagement(address newManager) internal {
    require(newManager != address(0), "ExtensionManager: new owner is 0 address");
    emit ExtensionManagerTransferred(_extensionManager, newManager);
    _extensionManager = newManager;
  }

  function forciblyAddExtension(address targetAddress, address addressToRegister, uint64 fromChainId) external onlyExtensionManager {
    ILockProxy lockProxy = ILockProxy(targetAddress);
    bytes memory payload = ZeroCopySink.WriteVarBytes(Utils.addressToBytes(addressToRegister));
    lockProxy.addExtension(payload, payload, fromChainId);
  }
}
