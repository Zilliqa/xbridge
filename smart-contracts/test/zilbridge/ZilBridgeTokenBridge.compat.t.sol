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

  function test_wrappedCompatibility() external {
    // Amusingly, because of the way SwitcheoToken works, we need to do a bridge transfer to get funds to the remote user that they can then
    // synthetically lock.
    transferToRemoteUser(address(nativelyOnSource), address(remoteNativelyOnSource), sourceUser, remoteUser, originalTokenSupply);
  }
}
