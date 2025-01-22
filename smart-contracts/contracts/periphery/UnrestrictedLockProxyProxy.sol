// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { Ownable2Step } from "@openzeppelin/contracts/access/Ownable2Step.sol";
import { EnumerableSet } from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import { ILockProxyExtensionTransfer } from "contracts/periphery/ILockProxyExtensionTransfer.sol";

/// @dev A variant of LockProxyProxy which doesn't do any checks. This is used on Zilliqa
/// where any token coming through the LockProxy should be manipulated by the extension
contract UnrestrictedLockProxyProxy is ILockProxyExtensionTransfer, Ownable2Step {
  using EnumerableSet for EnumerableSet.AddressSet;

  address public lockProxy;
  EnumerableSet.AddressSet legalCallers;

  error UnauthorizedCaller(address caller);

  constructor(address _owner, address _lockProxy) Ownable(_owner) {
    lockProxy = _lockProxy;
  }

  function addCaller(address _caller) onlyOwner public {
    legalCallers.add(_caller);

  }

  function removeCaller(address _caller) onlyOwner public {
    legalCallers.remove(_caller);
  }

  function enumerateCallers() public view returns (address[] memory) {
    return legalCallers.values();
  }

  modifier onlyValidCaller() {
    if (!legalCallers.contains(_msgSender())) {
        revert UnauthorizedCaller(_msgSender());
      }
    _;
  }

  function extensionTransfer(address _receivingAddress, address _assetHash, uint256 _amount) external onlyValidCaller returns (bool) {
    return ILockProxyExtensionTransfer(lockProxy).extensionTransfer(_receivingAddress, _assetHash, _amount);
  }
}
