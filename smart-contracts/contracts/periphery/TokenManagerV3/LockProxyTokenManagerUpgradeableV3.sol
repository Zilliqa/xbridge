// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV3, ITokenManager} from "contracts/periphery/TokenManagerV3/TokenManagerUpgradeableV3.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import { ILockProxyTokenManagerStorage, LockProxyTokenManagerStorage } from "contracts/periphery/LockProxyTokenManagerStorage.sol";

interface ILockProxyTokenManager is ILockProxyTokenManagerStorage {
  // Args in this order to match other token managers.
  event SentToLockProxy(address indexed token, address indexed sender, uint amount);
  event WithdrawnFromLockProxy(address indexed token, address indexed receipient, uint amount);
}

// Exists purely so that we can call the extensionTransfer() endpoint on the lock proxy without having
// to include its code here.
interface ILockProxyExtensionTransfer {
    function extensionTransfer(
        address _receivingAddress,
        address _assetHash,
        uint256 _amount
    )
        external
        returns (bool);
}

// This is the lock proxy token manager that runs on EVM chains. It talks to an EVM LockProxy.
contract LockProxyTokenManagerUpgradeableV3 is TokenManagerUpgradeableV3, ILockProxyTokenManager, LockProxyTokenManagerStorage {
  address public constant NATIVE_ASSET_HASH = address(0);

  constructor() {
    _disableInitializers();
  }

  function reinitialize(uint fees) external reinitializer(2) {
    _setFees(fees);
  }

  // Incoming currency - transfer into the lock proxy
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

  function _handleAccept(address token, address recipient, uint amount) internal override {
    address lockProxyAddress = getLockProxy();
    ILockProxyExtensionTransfer lp = ILockProxyExtensionTransfer(payable(lockProxyAddress));
    // Sadly, extensionTransfer() takes the same arguments as the withdrawn event but in a
    // different order. This will automagically transfer native token if token==0.

    // Native tokens are transferred by the call; for everyone else, it sets an allowance and we
    // then do the transfer from here.
    if (token == address(0)) {
      lp.extensionTransfer(recipient, address(0), amount);
    } else {
      lp.extensionTransfer(address(this), token, amount);
      IERC20 erc20token = IERC20(token);
      erc20token.transferFrom(address(lp), recipient, amount);
    }
    emit WithdrawnFromLockProxy(token, recipient, amount);
  }

  function setLockProxy(address lockProxy) external onlyOwner {
    _setLockProxy(lockProxy);
  }

}
