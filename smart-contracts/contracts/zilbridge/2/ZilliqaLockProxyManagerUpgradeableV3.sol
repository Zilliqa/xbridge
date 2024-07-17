// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV3, ITokenManager} from "contracts/periphery/TokenManagerV3/TokenManagerUpgradeableV3.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import { ILockProxyTokenManagerStorage, LockProxyTokenManagerStorage } from "contracts/zilbridge/2/LockProxyTokenManagerStorage.sol";

interface ILockProxyTokenManager is ILockProxyTokenManagerStorage {
  // Args in this order to match other token managers.
  event SentToLockProxy(address indexed token, address indexed sender, uint amount);
  event WithdrawnFromLockProxy(address indexed token, address indexed receipient, uint amount);
}

/*** @notice This is the lock proxy token manager that runs on Zilliqa chains.
 *  @TODO rename this - it's really just a LockAndReleaseTokenManager but with a native token escape.
 */
contract ZilliqaLockProxyTokenManagerUpgradeableV3 is TokenManagerUpgradeableV3, ILockProxyTokenManager, LockProxyTokenManagerStorage {
  address public constant NATIVE_ASSET_HASH = address(0);

  constructor() {
    _disableInitializers();
  }

  function reinitialize(uint fees) external reinitializer(2) {
    _setFees(fees);
  }

  function _handleTransfer(address /*token*/, address /*from*/, uint /*amount*/) internal pure override {
    revert("Not yet implemented");
  }

  function _handleAccept(address /* token */, address /*recipient*/, uint /*amount*/) internal pure override {
    revert("Not yet implemented");
  }

  function setLockProxy(address lockProxy) external onlyOwner {
    _setLockProxy(lockProxy);
  }

}
