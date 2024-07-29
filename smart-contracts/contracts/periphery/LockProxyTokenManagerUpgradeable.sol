// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeable, ITokenManager} from "contracts/periphery/TokenManagerUpgradeable.sol";
import { ILockProxyTokenManagerStorage, LockProxyTokenManagerStorage } from "contracts/periphery/LockProxyTokenManagerStorage.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface ILockProxyTokenManager is ITokenManager {
  // Args in this order to match other token managers.
  event SentToLockProxy(address indexed token, address indexed sender, uint amount);
  event WithdrawnFromLockProxy(address indexed token, address indexed receipient, uint amount);
  function setLockProxy(address lockProxy) external;
}

// This contract exists almost entirely to be used in tests to prove upgradeability.
contract LockProxyTokenManagerUpgradeable is
    ILockProxyTokenManager,
  TokenManagerUpgradeable,
  LockProxyTokenManagerStorage
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }


    function setLockProxy(address lockProxy) external override(ILockProxyTokenManagerStorage, ILockProxyTokenManager) onlyOwner {
      _setLockProxy(lockProxy);
    }

    function initialize(address _gateway, address lockProxy) external initializer {
        __TokenManager_init(_gateway);
        // for some reason we can't call setLockProxy() here, so ..
        _setLockProxy(lockProxy);
    }

    // Outgoing
    function _handleTransfer(
        address /* token */,
        address /* from */,
        uint /* amount */
    ) pure internal override {
      revert();
    }

    // Incoming
    function _handleAccept(
        address /* token */,
        address /* recipient */,
        uint /* amount */
    ) pure internal override {
      revert();
    }
}
