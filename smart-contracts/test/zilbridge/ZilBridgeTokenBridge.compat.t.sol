// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester, Vm} from "test/Tester.sol";
import {ITokenManagerStructs, TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseTokenManagerUpgradeableV3.sol";
import {MintAndBurnTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/MintAndBurnTokenManagerUpgradeableV3.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import {CallMetadata, IRelayerEvents} from "contracts/core/Relayer.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {TestToken} from "test/Helpers.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerDeployer} from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {MintAndBurnTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/MintAndBurnTokenManagerDeployer.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import { ZilBridgeFixture } from "test/zilbridge/DeployZilBridge.t.sol";
import { MockLockProxy } from "./MockLockProxy.sol";
import { ZilBridgeTokenBridgeIntegrationFixture } from "./ZilBridgeTokenIntegrationFixture.t.sol";
import { IERC20 } from "openzeppelin-contracts/contracts/interfaces/IERC20.sol";

/*** @notice provides utility routines for the compatibility tests. These are very similar to the
 * orutines in the integration tests.
 */
contract ZilBridgeTokenBridgeCompatibilityFixture is ZilBridgeTokenBridgeIntegrationFixture {
  using MessageHashUtils for bytes;

  /// @notice send amount wrapped tokens to the remote user.
  function transferToRemoteUser(address sourceToken_, address remoteToken_,
                                            address sourceUser_, address remoteUser_, uint256 amount_) public {
    startHoax(sourceUser_);
    uint sourceChainId_ = block.chainid;
    uint remoteChainId_ = block.chainid;
    uint valueToSend = fees;
    uint sourceBalance;
    if (sourceToken_ == address(0)) {
      // Check for native
      assertGe(sourceUser_.balance, amount_);
      sourceBalance = sourceUser_.balance;
      valueToSend += amount_;
    } else {
      // Check that the source user has the funds.
      sourceBalance = IERC20(sourceToken_).balanceOf(sourceUser_);
      assertGe(sourceBalance, amount_);
      // Set up an allowance
      IERC20(sourceToken_).approve(address(sourceTokenManager), amount_);
    }
    uint remoteBalance;
    if (remoteToken_ == address(0)) {
      remoteBalance = remoteUser_.balance;
    } else {
      remoteBalance = IERC20(remoteToken_).balanceOf(remoteUser_);
    }

    bytes memory data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(sourceChainId_, address(sourceTokenManager)),
        // To
        abi.encode(ITokenManagerStructs.AcceptArgs(address(remoteToken_), remoteUser_, amount_)));

    vm.expectEmit(address(sourceChainGateway));
    emit IRelayerEvents.Relayed(remoteChainId_,
                                address(remoteTokenManager), data, 1_000_000, 0);
    sourceTokenManager.transfer{value: valueToSend} (
        address(sourceToken_), remoteChainId_, remoteUser_, amount_);
    vm.startPrank(validator);
    bytes[] memory signatures = new bytes[](1);
    signatures[0] = sign(validatorWallet, abi.encode(sourceChainId_, remoteChainId_,
                                                     address(remoteTokenManager), data,
                                                     1_000_000, 0)
                         .toEthSignedMessageHash());
    remoteChainGateway.dispatch(sourceChainId_,
                                address(remoteTokenManager),
                                data, 1_000_000, 0, signatures);
    if (remoteToken_ == address(0)) {
      assertGe(remoteUser_.balance, remoteBalance + amount_);
    } else {
      assertEq(IERC20(remoteToken_).balanceOf(remoteUser_), remoteBalance + amount_);
    }
    if (sourceToken_ == address(0)) {
      assertLe(sourceUser_.balance, sourceBalance - amount_);
    } else {
      assertEq(IERC20(sourceToken_).balanceOf(sourceUser_), sourceBalance - amount_);
    }
  }

  /// @notice send amount wrapped tokens to a source user.
  function transferFromRemoteUser(address sourceToken_, address remoteToken_,
                                            address sourceUser_, address remoteUser_, uint256 amount_) public {
    startHoax(remoteUser_);
    uint sourceChainId_ = block.chainid;
    uint remoteChainId_ = block.chainid;
    uint valueToSend = fees;
    uint remoteBalance;
    if (remoteToken_ == address(0)) {
      // Check for native
      assertGe(remoteUser_.balance, amount_);
      remoteBalance = remoteUser_.balance;
      valueToSend += amount_;
    } else {
      // Check that the source user has the funds.
      remoteBalance = IERC20(remoteToken_).balanceOf(remoteUser_);
      assertGe(remoteBalance, amount_);
      // Set up an allowance
      IERC20(remoteToken_).approve(address(remoteTokenManager), amount_);
    }
    uint sourceBalance;
    if (sourceToken_ == address(0)) {
      sourceBalance = sourceUser_.balance;
    } else {
      sourceBalance = IERC20(sourceToken_).balanceOf(sourceUser_);
    }

    bytes memory data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(remoteChainId_, address(remoteTokenManager)),
        // To
        abi.encode(ITokenManagerStructs.AcceptArgs(address(sourceToken_), sourceUser_, amount_)));

    vm.expectEmit(address(remoteChainGateway));
    emit IRelayerEvents.Relayed(sourceChainId_,
                                address(sourceTokenManager), data, 1_000_000, 0);
    remoteTokenManager.transfer{value: valueToSend} (
        address(remoteToken_), sourceChainId_, sourceUser_, amount_);
    vm.startPrank(validator);
    bytes[] memory signatures = new bytes[](1);
    signatures[0] = sign(validatorWallet, abi.encode(remoteChainId_, sourceChainId_,
                                                     address(sourceTokenManager), data,
                                                     1_000_000, 0)
                         .toEthSignedMessageHash());
    sourceChainGateway.dispatch(remoteChainId_,
                                address(sourceTokenManager),
                                data, 1_000_000, 0, signatures);
    if (sourceToken_ == address(0)) {
      assertGe(sourceUser_.balance, sourceBalance + amount_);
    } else {
      assertEq(IERC20(sourceToken_).balanceOf(sourceUser_), sourceBalance + amount_);
    }
    if (remoteToken_ == address(0)) {
      assertLe(remoteUser_.balance, remoteBalance - amount_);
    } else {
      assertEq(IERC20(remoteToken_).balanceOf(remoteUser_), remoteBalance - amount_);
    }
  }

}

/// @title Test that assets bridged via ZilBridge can be recovered via XBridge
/// @author rrw
/*** @notice This test is a replica of ZilBridgeTokenBridgeIntegrationTest which bridges assets that we fake up
 * ( via MockLockProxy ) to have been locked by the original zilBridge, to prove that we can recover
 * them via XBridge.
 */
contract ZilBridgeTokenBridgeCompatibilityTest is ZilBridgeTokenBridgeCompatibilityFixture {
  using MessageHashUtils for bytes;

  function setUp() external {
    installContracts();
  }

  function test_wrappedCompatibilityForward() external {
    // Get an amount
    uint256 amount = originalTokenSupply;
    // Transfer it synthetically to the lock proxy at the source end.
    startHoax(sourceUser);
    nativelyOnSource.approve(address(lockProxy), amount);
    lockProxy.testing_transferIn(address(nativelyOnSource), amount, amount);

    // Use the mock lock proxy to simulate transferring that to the remote user.
    mockRemoteLockProxy.testing_transferOut(remoteUser, address(remoteNativelyOnSource), amount);

    assertEq(remoteNativelyOnSource.balanceOf(remoteUser), amount);
    assertEq(nativelyOnSource.balanceOf(sourceUser), 0);
    assertEq(nativelyOnSource.balanceOf(address(lockProxy)), amount);

    // OK. Now transfer it back again.
    transferFromRemoteUser(address(nativelyOnSource), address(remoteNativelyOnSource),
                           sourceUser, remoteUser, amount);
  }

  function test_wrappedCompatibilityNative() external {
    // Get am amount
    uint256 amount = originalTokenSupply; 
    startHoax(sourceUser);
    uint256 gas = 1 ether;
    vm.deal(sourceUser, amount + gas);

    uint256 sourceBalance = sourceUser.balance;
    uint256 lockBalance = address(lockProxy).balance;
    lockProxy.testing_transferIn{value: originalTokenSupply}(address(0), amount, amount);
    mockRemoteLockProxy.testing_transferOut(remoteUser, address(remoteBridgedGasToken), amount);

    assertEq(remoteBridgedGasToken.balanceOf(remoteUser), amount);
    assertLe(sourceUser.balance, sourceBalance - amount);
    assertEq(address(lockProxy).balance, lockBalance + amount);

    // OK. Now transfer it back again.
    transferFromRemoteUser(address(0), address(remoteBridgedGasToken),
                           sourceUser, remoteUser, amount);
  }

  function test_wrappedCompatibilityBackward() external {
    // Get an amount
    uint256 amount = originalTokenSupply;
    // Transfer it synthetically to the lock proxy at the remote
    startHoax(remoteUser);
    nativelyOnRemote.approve(address(mockRemoteLockProxy), amount);
    mockRemoteLockProxy.testing_transferIn(address(nativelyOnRemote), amount, amount);
    lockProxy.testing_transferOut(sourceUser, address(sourceNativelyOnRemote), amount);

    assertEq(sourceNativelyOnRemote.balanceOf(sourceUser), amount);
    assertEq(nativelyOnRemote.balanceOf(remoteUser), 0);
    assertEq(nativelyOnRemote.balanceOf(address(mockRemoteLockProxy)), amount);

    // Now transfer it back again
    transferToRemoteUser(address(sourceNativelyOnRemote), address(nativelyOnRemote),
                         sourceUser, remoteUser, originalTokenSupply);
  }
}
