// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV4, ITokenManager} from "contracts/periphery/TokenManagerV4/TokenManagerUpgradeableV4.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {IRelayer, CallMetadata} from "contracts/core/Relayer.sol";

interface ILockAndReleaseOrNativeTokenManager {
    event Locked(address indexed token, address indexed from, uint amount);
    event Released(
        address indexed token,
        address indexed recipient,
        uint amount
    );
}

contract LockAndReleaseOrNativeTokenManagerUpgradeableV4 is
    ILockAndReleaseOrNativeTokenManager,
    TokenManagerUpgradeableV4
{
    address public constant NATIVE_ASSET_HASH = address(0);

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    /// @dev Allow this contract to receive native tokens.
    receive() external payable {}

    // Outgoing
    function _handleTransfer(
        address token,
        address from,
        uint amount
    ) internal override {
      if (token == NATIVE_ASSET_HASH) {
        (bool success, ) = payable(this).call{ value: amount }("");
        require(success, "Native asset transfer failed");
      } else {
        IERC20(token).transferFrom(from, address(this), amount);
      }
      emit Locked(token, from, amount);
    }

    // Incoming
    function _handleAccept(
        address token,
        address recipient,
        uint amount
    ) internal override {
      if (token == NATIVE_ASSET_HASH) {
        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Native asset transfer failed");
      } else {
        IERC20(token).transfer(recipient, amount);
      }
      emit Released(token, recipient, amount);
    }
}
