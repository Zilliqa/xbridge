// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV4, ITokenManager} from "contracts/periphery/TokenManagerV3/TokenManagerUpgradeableV4.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import { ILockProxyTokenManagerStorage, LockProxyTokenManagerStorage } from "contracts/periphery/LockProxyTokenManagerStorage.sol";
import { ILockProxyExtensionTransfer } from "contracts/periphery/ILockProxyExtensionTransfer.sol";

interface ILockProxyTokenManager is ILockProxyTokenManagerStorage {
  // Args in this order to match other token managers.
  event SentToLockProxy(address indexed token, address indexed sender, uint amount);
  event WithdrawnFromLockProxy(address indexed token, address indexed receipient, uint amount);
}

// This is the lock proxy token manager that runs on EVM chains. It talks to an EVM LockProxy.
contract LockProxyTokenManagerUpgradeableV4 is TokenManagerUpgradeableV4, ILockProxyTokenManager, LockProxyTokenManagerStorage {
  address public constant NATIVE_ASSET_HASH = address(0);

  constructor() {
    _disableInitializers();
  }

  function reinitialize(uint fees) external reinitializer(2) {
    _setFees(fees);
  }

  // Incoming currency - transfer into the lock proxy (directly!)
  function _handleTransfer(address token, address from, uint amount) internal override {
    address lockProxyAddress = getLockProxy();
    // Just transfer value to the lock proxy.
    if (token == NATIVE_ASSET_HASH) {
      (bool success, ) = lockProxyAddress.call{value: amount}("");
      emit SentToLockProxy(token, from, amount);
      require(success, "Transfer failed");
      return;
    }

    IERC20 erc20token = IERC20(token);
    erc20token.transferFrom(from, address(lockProxyAddress), amount);
    emit SentToLockProxy(token, from, amount);
  }

  // Withdrawals are processed via the lockProxyProxy.
  function _handleAccept(address token, address recipient, uint amount) internal override {
    address lockProxyProxyAddress = getLockProxyProxy();
    address lockProxyAddress = getLockProxy();
    ILockProxyExtensionTransfer lp = ILockProxyExtensionTransfer(payable(lockProxyProxyAddress));
    // Sadly, extensionTransfer() takes the same arguments as the withdrawn event but in a
    // different order. This will automagically transfer native token if token==0.

    // Native tokens are transferred by the call; for everyone else, it sets an allowance and we
    // then do the transfer from here.
    if (token == address(0)) {
      lp.extensionTransfer(recipient, address(0), amount);
    } else {
      lp.extensionTransfer(address(this), token, amount);
      IERC20 erc20token = IERC20(token);
      // Although the lockProxyProxy is the registered extension, the tokens are held by the actual
      // lockProxy
      erc20token.transferFrom(lockProxyAddress, recipient, amount);
    }
    emit WithdrawnFromLockProxy(token, recipient, amount);
  }

  function setLockProxyData(address lockProxy, address lockProxyProxy) external onlyOwner {
    _setLockProxyData(lockProxy, lockProxyProxy);
  }

}
