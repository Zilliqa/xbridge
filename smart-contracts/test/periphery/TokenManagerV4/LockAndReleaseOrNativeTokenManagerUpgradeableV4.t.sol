// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {Tester} from "test/Tester.sol";
import {LockAndReleaseTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/LockAndReleaseTokenManagerUpgradeableV2.sol";
import {LockAndReleaseTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseTokenManagerUpgradeableV3.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ITokenManager, ITokenManagerFees, ITokenManagerStructs, ITokenManagerEvents} from "contracts/periphery/TokenManagerV2/TokenManagerUpgradeableV2.sol";
import {ITokenManagerFeesEvents} from "contracts/periphery/TokenManagerV2/TokenManagerFees.sol";
import {IRelayer} from "contracts/core/Relayer.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestToken} from "test/Helpers.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";

interface IPausable {
    event Paused(address account);
    event Unpaused(address account);
}

contract LockAndReleaseTokenManagerUpgradeableV4Tests is
    Tester,
    ITokenManagerEvents,
    ITokenManagerStructs,
    ITokenManagerFeesEvents,
    IPausable,
    LockAndReleaseTokenManagerDeployer
{
    address deployer = vm.addr(1);
    address chainGateway = vm.addr(102);
    address user = vm.createWallet("user").addr;

    RemoteToken remoteToken =
        RemoteToken({
            token: vm.createWallet("remoteToken").addr,
            tokenManager: vm.createWallet("remoteTokenManager").addr,
            chainId: 101
        });
    uint transferAmount = 10 ether;
    uint fees = 0.1 ether;

    LockAndReleaseTokenManagerUpgradeableV2 tokenManagerV2;
    LockAndReleaseTokenManagerUpgradeableV3 tokenManagerV3;
    LockAndReleaseOrNativeTokenManagerUpgradeableV4 tokenManagerV4;
    TestToken token;
    TestToken unregisteredToken;

    function setUp() external {
        vm.startPrank(deployer);
        tokenManagerV2 = deployLockAndReleaseTokenManagerV2(chainGateway, fees);

        // Deploy new token
        token = new TestToken(transferAmount);
        tokenManagerV2.registerToken(address(token), remoteToken);
        unregisteredToken = new TestToken(transferAmount);

        // Premint some tokens for user testing
        token.transfer(user, transferAmount);
        assertEq(token.balanceOf(user), transferAmount);
        assertEq(token.balanceOf(deployer), 0);

        // Carry out upgrade v3
        address implementationV3 = address(
            new LockAndReleaseTokenManagerUpgradeableV3()
        );
        tokenManagerV2.upgradeToAndCall(implementationV3, "");
        tokenManagerV3 = LockAndReleaseTokenManagerUpgradeableV3(
            address(tokenManagerV2)
        );
        address implementationV4 = address(
            new LockAndReleaseOrNativeTokenManagerUpgradeableV4()
        );
        tokenManagerV3.upgradeToAndCall(implementationV4, "");
        // Now v4
        tokenManagerV4 = LockAndReleaseOrNativeTokenManagerUpgradeableV4(
            payable(address(tokenManagerV3))
        );
        vm.stopPrank();
    }

    function test_feesOnTransfer() external {
        startHoax(user);

        token.approve(address(tokenManagerV2), transferAmount);

        vm.mockCall(
            chainGateway,
            abi.encodeCall(
                IRelayer.relayWithMetadata,
                (
                    remoteToken.chainId,
                    remoteToken.tokenManager,
                    ITokenManager.accept.selector,
                    abi.encode(
                        AcceptArgs(remoteToken.token, user, transferAmount)
                    ),
                    1_000_000
                )
            ),
            abi.encode(0)
        );
        tokenManagerV2.transfer{value: fees}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );
        assertEq(token.balanceOf(address(tokenManagerV2)), transferAmount);
        assertEq(token.balanceOf(user), 0);
        assertEq(address(tokenManagerV2).balance, fees);

        vm.stopPrank();
    }

    function test_extraFeesOnTransfer() external {
        startHoax(user);

        token.approve(address(tokenManagerV2), transferAmount);

        vm.mockCall(
            chainGateway,
            abi.encodeCall(
                IRelayer.relayWithMetadata,
                (
                    remoteToken.chainId,
                    remoteToken.tokenManager,
                    ITokenManager.accept.selector,
                    abi.encode(
                        AcceptArgs(remoteToken.token, user, transferAmount)
                    ),
                    1_000_000
                )
            ),
            abi.encode(0)
        );
        tokenManagerV2.transfer{value: fees * 2}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );
        assertEq(token.balanceOf(address(tokenManagerV2)), transferAmount);
        assertEq(token.balanceOf(user), 0);
        assertEq(address(tokenManagerV2).balance, fees * 2);

        vm.stopPrank();
    }

    function test_RevertWhenNoFeesProvidedOnTransfer() external {
        startHoax(user);

        token.approve(address(tokenManagerV2), transferAmount);

        vm.expectRevert(
            abi.encodeWithSelector(
                ITokenManagerFees.InsufficientFees.selector,
                0,
                fees
            )
        );
        tokenManagerV2.transfer{value: 0}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );

        assertEq(token.balanceOf(address(tokenManagerV2)), 0);
        assertEq(token.balanceOf(user), transferAmount);
        assertEq(address(tokenManagerV2).balance, 0);

        vm.stopPrank();
    }

    function test_RevertWhenInsufficientFeesProvidedOnTransfer() external {
        startHoax(user);
        uint halfFees = fees / 2;

        token.approve(address(tokenManagerV2), transferAmount);

        vm.expectRevert(
            abi.encodeWithSelector(
                ITokenManagerFees.InsufficientFees.selector,
                halfFees,
                fees
            )
        );
        tokenManagerV2.transfer{value: halfFees}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );

        assertEq(token.balanceOf(address(tokenManagerV2)), 0);
        assertEq(token.balanceOf(user), transferAmount);
        assertEq(address(tokenManagerV2).balance, 0);

        vm.stopPrank();
    }

    function test_RevertTransferWhenPaused() external {
        vm.prank(deployer);
        vm.expectEmit(address(tokenManagerV2));
        emit IPausable.Paused(deployer);
        tokenManagerV2.pause();

        assertEq(tokenManagerV2.paused(), true);

        startHoax(user);
        uint halfFees = fees / 2;

        token.approve(address(tokenManagerV2), transferAmount);

        vm.expectRevert(PausableUpgradeable.EnforcedPause.selector);
        tokenManagerV2.transfer{value: halfFees}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );

        assertEq(token.balanceOf(address(tokenManagerV2)), 0);
        assertEq(token.balanceOf(user), transferAmount);
        assertEq(address(tokenManagerV2).balance, 0);

        vm.stopPrank();
    }

    function test_RevertNonOwnerAttemptPause() external {
        address randomUser = vm.createWallet("randomUser").addr;

        vm.prank(randomUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );
        tokenManagerV2.pause();

        assertEq(tokenManagerV2.paused(), false);
    }

    function test_withdrawFees() external {
        uint withdrawAmount = 1 ether;
        assertEq(address(tokenManagerV2).balance, 0);
        assertEq(deployer.balance, 0);

        vm.deal(address(tokenManagerV2), withdrawAmount);
        assertEq(address(tokenManagerV2).balance, withdrawAmount);

        vm.prank(deployer);
        vm.expectEmit(address(tokenManagerV2));
        emit ITokenManagerFeesEvents.FeesWithdrawn(withdrawAmount);
        tokenManagerV2.withdrawFees(payable(deployer));

        assertEq(address(deployer).balance, withdrawAmount);
    }

    function test_withdrawFeesWhenNoFees() external {
        assertEq(address(tokenManagerV2).balance, 0);
        assertEq(deployer.balance, 0);

        vm.prank(deployer);
        vm.expectEmit(address(tokenManagerV2));
        emit ITokenManagerFeesEvents.FeesWithdrawn(0);
        tokenManagerV2.withdrawFees(payable(deployer));

        assertEq(address(deployer).balance, 0);
    }

    function test_setNewFeesAndTransfer() external {
        uint newFees = 1 ether;

        // Test setting fees
        vm.prank(deployer);
        vm.expectEmit(address(tokenManagerV2));
        emit ITokenManagerFeesEvents.FeesUpdated(fees, newFees);
        tokenManagerV2.setFees(newFees);

        assertEq(tokenManagerV2.getFees(), newFees);

        // Test transfer
        startHoax(user);

        token.approve(address(tokenManagerV2), transferAmount);
        vm.mockCall(
            chainGateway,
            abi.encodeCall(
                IRelayer.relayWithMetadata,
                (
                    remoteToken.chainId,
                    remoteToken.tokenManager,
                    ITokenManager.accept.selector,
                    abi.encode(
                        AcceptArgs(remoteToken.token, user, transferAmount)
                    ),
                    1_000_000
                )
            ),
            abi.encode(0)
        );
        tokenManagerV2.transfer{value: newFees}(
            address(token),
            remoteToken.chainId,
            user,
            transferAmount
        );

        assertEq(token.balanceOf(address(tokenManagerV2)), transferAmount);
        assertEq(token.balanceOf(user), 0);
        assertEq(address(tokenManagerV2).balance, newFees);

        vm.stopPrank();
    }

    function test_RevertNonOwnerSetFees() external {
        uint newFees = 1 ether;
        address randomUser = vm.createWallet("randomUser").addr;

        // Test setting fees
        vm.prank(randomUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );
        tokenManagerV2.setFees(newFees);

        assertEq(tokenManagerV2.getFees(), fees);
    }

    function test_RevertNonOwnerWithdrawFees() external {
        uint balance = 2 ether;
        vm.deal(address(tokenManagerV2), balance);
        address randomUser = vm.createWallet("randomUser").addr;

        // Test setting fees
        vm.prank(randomUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );
        tokenManagerV2.withdrawFees(payable(randomUser));

        assertEq(address(tokenManagerV2).balance, balance);
    }

    function test_RevertNonOwnerUnpause() external {
        address randomUser = vm.createWallet("randomUser").addr;

        // Pause first
        vm.prank(deployer);
        tokenManagerV2.pause();

        assertEq(tokenManagerV2.paused(), true);

        // Test setting fees
        vm.prank(randomUser);
        vm.expectRevert(
            abi.encodeWithSelector(
                OwnableUpgradeable.OwnableUnauthorizedAccount.selector,
                randomUser
            )
        );
        tokenManagerV2.unpause();

        assertEq(tokenManagerV2.paused(), true);
    }

    function test_RevertInvalidChainId() external {
      address receiver = vm.addr(2);
      vm.expectRevert();
      tokenManagerV2.transfer{value: fees}( remoteToken.token, remoteToken.chainId, receiver, 100 );
    }

    function test_RevertInvalidRouting() external {
      address receiver = vm.addr(2);
      vm.expectRevert();
      tokenManagerV2.transfer{value: fees}( address(unregisteredToken), 101, receiver, 100 );
    }
}

