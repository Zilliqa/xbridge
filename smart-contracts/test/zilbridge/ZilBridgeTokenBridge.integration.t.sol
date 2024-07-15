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

/// @title A general integration test for ZilBridge.
/// @author rrw
/*** @notice Tests some of the basic transfer routes: TestToken -> SwitcheoToken and back,
 *  and native token -> SwitcheoToken and back. Testing SwitcheoToken -> nativetoken is
 *  skipped, partly because it is symmetric and partly because it's not possible in zq1
 *  anyway.
 */
contract ZilBridgeTokenBridgeIntegrationTest is ZilBridgeTokenBridgeIntegrationFixture {
  using MessageHashUtils for bytes;


  function setUp() external {
    installContracts();
  }

  /// @notice test the happy path for a wrapped token to wrapped token exchange from TestToken to SwitcheoToken and back.
  function test_happyPathWrappedToRemote() external {
    startHoax(sourceUser);
    uint amount = originalTokenSupply;
    uint sourceChainId = block.chainid;
    uint remoteChainId = block.chainid;
    assertEq(nativelyOnSource.balanceOf(sourceUser), amount);

    bytes memory data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(sourceChainId, address(sourceTokenManager)), 
        // To
        abi.encode(ITokenManagerStructs.AcceptArgs(address(remoteNativelyOnSource), remoteUser, amount)));

    // approval goes to the token manager, which will transfer value to/from the lock proxy for you.
    nativelyOnSource.approve(address(sourceTokenManager), amount);

    // Ask the source token manager to take the source tokens and emit a relayed event
    // (this should transfer the tokens to the lock proxy)
    // TBD: Check this.
    vm.expectEmit(address(sourceChainGateway));
    emit IRelayerEvents.Relayed(remoteChainId,
                                address(remoteTokenManager), data, 1_000_000, 0);
    sourceTokenManager.transfer{value: fees}(
        address(nativelyOnSource), remoteChainId, remoteUser, amount);

    // Now bridge ..
    vm.startPrank(validator);
    bytes[] memory signatures = new bytes[](1);
    signatures[0] = sign(validatorWallet, abi.encode(sourceChainId, remoteChainId,
                                                     address(remoteTokenManager),
                                                     data,
                                                     1_000_000, 0)
                         .toEthSignedMessageHash()
                         );
    remoteChainGateway.dispatch(sourceChainId,
                                address(remoteTokenManager),
                                data,
                                1_000_000,
                                0,
                                signatures);

    // OK. Now ..
    assertEq(remoteNativelyOnSource.balanceOf(remoteUser), amount);
    assertEq(remoteNativelyOnSource.totalSupply(), amount);
    assertEq(nativelyOnSource.totalSupply(), amount);
    assertEq(nativelyOnSource.balanceOf(sourceUser), 0);

    // Send it back again.
    startHoax(remoteUser);
    remoteNativelyOnSource.approve(address(remoteTokenManager), amount);
    remoteTokenManager.transfer{value: fees}(
         address(remoteNativelyOnSource), sourceChainId, sourceUser, amount);

    vm.startPrank(validator);
    data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(remoteChainId, address(remoteTokenManager)),
        // To
        abi.encode(
            ITokenManagerStructs.AcceptArgs(address(nativelyOnSource), sourceUser, amount)
                   ));
    signatures[0] = sign(
        validatorWallet,
        abi.encode(remoteChainId, sourceChainId,
                   address(sourceTokenManager),
                   data,
                   1_000_000,
                   0).toEthSignedMessageHash());
    sourceChainGateway.dispatch(remoteChainId,
                                address(sourceTokenManager),
                                data,
                                1_000_000,
                                0,
                                signatures);
    // Check balances are back ..
    assertEq(remoteNativelyOnSource.balanceOf(remoteUser), 0);
    assertEq(nativelyOnSource.balanceOf(sourceUser), amount);
  }


  /// @notice Test native token to SwitcheoToken and back.
  function test_happyPathNativeToken() external {
    startHoax(sourceUser);
    uint256 amount = originalTokenSupply;

    // add some to account for gas.
    uint accountForGas = 1 ether;
    vm.deal(sourceUser, amount + accountForGas);
    vm.deal(remoteUser, accountForGas);
    uint256 initialSourceBalance = sourceUser.balance;
    uint sourceChainId = block.chainid;
    uint remoteChainId = block.chainid;
    assertGt(sourceUser.balance, originalTokenSupply);

    bytes memory data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(sourceChainId, address(sourceTokenManager)),
        // To
        abi.encode(ITokenManagerStructs.AcceptArgs(address(remoteBridgedGasToken), remoteUser, amount)));
    vm.expectEmit(address(sourceChainGateway));
    emit IRelayerEvents.Relayed(remoteChainId,
                                address(remoteTokenManager), data, 1_000_000, 0);
    sourceTokenManager.transfer{ value: fees + originalTokenSupply }(
        address(0), remoteChainId, remoteUser, amount);

    // Bridge!
    vm.startPrank(validator);
    bytes[] memory signatures = new bytes[](1);
    signatures[0] = sign(validatorWallet, abi.encode(sourceChainId, remoteChainId,
                                                     address(remoteTokenManager),
                                                     data,
                                                     1_000_000, 0)
                         .toEthSignedMessageHash());

    remoteChainGateway.dispatch(sourceChainId, address(remoteTokenManager), data, 1_000_000, 0, signatures);

    // The source user should now have less balance then accountForGas
    assertLe(sourceUser.balance, initialSourceBalance - amount);
    uint256 sourceUserBalanceAfterTransfer = sourceUser.balance;
    // The lock proxy should have the balance.
    assertEq(address(lockProxy).balance, amount);
    // The remote user should have the right number of wrapped tokens
    assertEq(remoteBridgedGasToken.balanceOf(sourceUser), 0);
    assertEq(remoteBridgedGasToken.balanceOf(remoteUser), amount);
    assertEq(remoteBridgedGasToken.totalSupply(), amount);

    // ..aaand send them all back again
    vm.startPrank(remoteUser);
    remoteBridgedGasToken.approve(address(remoteTokenManager), amount);
    remoteTokenManager.transfer{value: fees}(
        address(remoteBridgedGasToken), sourceChainId, sourceUser, amount);
    vm.startPrank(validator);
    data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(remoteChainId, address(remoteTokenManager)),
        // To
        abi.encode(
            ITokenManagerStructs.AcceptArgs(address(0), sourceUser, amount)));
    signatures[0] = sign(
        validatorWallet,
        abi.encode(remoteChainId, sourceChainId,
                   address(sourceTokenManager),
                   data,
                   1_000_000, 0).toEthSignedMessageHash());
    sourceChainGateway.dispatch(remoteChainId,
                                address(sourceTokenManager),
                                data,
                                1_000_000,
                                0,
                                signatures);
    // Balances should now be back
    assertEq(sourceUser.balance, sourceUserBalanceAfterTransfer + amount);
    assertEq(remoteBridgedGasToken.balanceOf(remoteUser), 0);
    // Weirdly, the supply is nondecreasing - this seems to be intentional in SwitcheoToken...
    assertEq(remoteBridgedGasToken.totalSupply(), amount);
  }

}
