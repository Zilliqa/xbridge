// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

// The part of the LockProxy extension interface that allows us to mint and burn
// tokens.
interface ILockProxyExtensionTransfer {
  function extensionTransfer(
      address _receivingAddress,
      address _assetHash,
      uint256 _amount
  ) external returns (bool);
}
