// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV3, ITokenManager} from "contracts/periphery/TokenManagerV3/TokenManagerUpgradeableV3.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";

interface ILockProxyTokenManager {
  // Args in this order to match other token managers.
  event SentToLockProxy(address indexed token, address indexed sender, uint amount);
  event WithdrawnFromLockProxy(address indexed token, address indexed receipient, uint amount);
}

contract LockProxyTokenManagerUpgradeableV3 is TokenManagerUpgradeableV3, ILockProxyTokenManager {
  address _lockProxyAddress;
  address public constant NATIVE_ASSET_HASH = address(0);

  constructor(address lockProxyAddress) {
    _disableInitializers();
    _lockProxyAddress = lockProxyAddress;
  }

  function changeLockProxy(address newLockProxy) public onlyOwner {
    _lockProxyAddress = newLockProxy;
  }

  // Incoming currency - transfer into the lock proxy
  function _handleTransfer(address token, address from, uint amount) internal override {
    // Just transfer value to the lock proxy.
    if (token == NATIVE_ASSET_HASH) {
      (bool success, ) = _lockProxyAddress.call{value: amount}("");
      emit SentToLockProxy(token, from, amount);
      require(success, "Transfer failed");
      return;
    }

    IERC20 erc20token = IERC20(token);
    erc20token.transferFrom(from, address(_lockProxyAddress), amount);
    emit SentToLockProxy(token, from, amount);
  }

  function _handleAccept(address token, address recipient, uint amount) internal override {
    LockProxy lp = LockProxy(payable(_lockProxyAddress));
    // Sadly, extensionTransfer() takes the same arguments as the withdrawn event but in a
    // different order. This will automagically transfer native token if token==0.
    lp.extensionTransfer(recipient, token, amount);
    emit WithdrawnFromLockProxy(token, recipient, amount);
  }
}
