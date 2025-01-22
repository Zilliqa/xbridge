// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {Tester} from "test/Tester.sol";
import {TokenManagerUpgradeableV4, ITokenManagerV4Events} from "contracts/periphery/TokenManagerV4/TokenManagerUpgradeableV4.sol";
import {ITokenManager, ITokenManagerFees, ITokenManagerStructs, ITokenManagerEvents} from "contracts/periphery/TokenManagerV2/TokenManagerUpgradeableV2.sol";
import {ITokenManagerFeesEvents} from "contracts/periphery/TokenManagerV2/TokenManagerFees.sol";
import {CallMetadata, IRelayer, IRelayerEvents} from "contracts/core/Relayer.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestToken} from "test/Helpers.sol";
import {TestTokenManagerDeployer, ITestTokenManagerEvents, TestTokenManagerUpgradeableV4 } from "test/periphery/TokenManagerDeployers/TestTokenManagerDeployer.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";

contract TokenManagerUpgradeableV4Tests is Tester, ITokenManagerStructs, ITokenManagerEvents, ITokenManagerV4Events, TestTokenManagerDeployer, IRelayerEvents, ITestTokenManagerEvents {
  address deployer = vm.addr(1);
  address user = vm.createWallet("user").addr;
  address user2 = vm.createWallet("user2").addr;
  uint fees = 0.1 ether;
  ValidatorManager validatorManager;
  ChainGateway chainGateway;
  TokenManagerUpgradeableV4 tokenManager;
  TestToken token1;
  TestToken token2;
  address remoteTokenAddr = vm.createWallet("remoteToken").addr;
  address remoteTokenManagerAddr = vm.createWallet("remoteTokenManager").addr;
  uint remoteChainId = 101;
  uint sourceChainId = 21023;
  RemoteToken remoteToken =
      RemoteToken({
       token: remoteTokenAddr,
       tokenManager: remoteTokenManagerAddr,
       chainId: remoteChainId
        });
  uint transferAmount = 10 ether;

  function setUp() external {
    vm.chainId(sourceChainId);
    vm.startPrank(deployer);
    validatorManager = new ValidatorManager(address(deployer));
    chainGateway = new ChainGateway(address(validatorManager), address(deployer));
    tokenManager = deployTestTokenManagerV4(address(chainGateway), fees);
    chainGateway.register(address(tokenManager));
    token1 = new TestToken(transferAmount);
    token2 = new TestToken(transferAmount);
    vm.stopPrank();
  }

  // You shouldn't be able to send a token for which a routing record doesn't exist.
  function test_invalidRouting() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, 0);
    vm.stopPrank();
    startHoax(user);
    // Legit transfers should succeeed
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, user2, 1_000_000);

    // Transfers to the wrong chain id should fail.
    vm.expectRevert();
    tokenManager.transfer{value: fees}(address(token1), remoteChainId+1, user2, 1_000_000);

    // Transfers for the wrong token should fail.
    vm.expectRevert();
    tokenManager.transfer{value: fees}(address(token2), remoteChainId, user2, 1_000_000);
    vm.stopPrank();
  }

  // You shouldn't be able to remove a token without being the owner
  function test_removeTokenPermissions() external {
    startHoax(deployer);
    assertEq(tokenManager.owner(), deployer);

    tokenManager.registerTokenWithScale(address(token1), remoteToken, 2);
    {
      RemoteToken memory tokrec;
      int8 tokscale;
      (tokrec, tokscale) = tokenManager.getRemoteTokenWithScale(address(token1), remoteChainId);
      assertEq(tokrec.chainId, remoteChainId);
      assertEq(tokrec.token, remoteTokenAddr);
      assertEq(tokrec.tokenManager, remoteTokenManagerAddr);
      assertEq(tokscale, 2);
    }
    vm.stopPrank();

    startHoax(user);
    vm.expectRevert();
    tokenManager.removeToken(address(token1), remoteChainId);
    vm.stopPrank();
  }

  // You shouldn't be able to register a token without being the owner.
  function test_registerWithScalePermissions() external {
    startHoax(user);
    vm.expectRevert();
    tokenManager.registerTokenWithScale(address(token1), remoteToken, 0);

    // Scale for unregistered tokens should be 0
    RemoteToken memory tokrec;
    int8 tokscale;
    (tokrec, tokscale) = tokenManager.getRemoteTokenWithScale(address(token1), 101);
    assertEq(tokrec.chainId, 0);
    assertEq(tokrec.token, address(0));
    assertEq(tokrec.tokenManager, address(0));
    assertEq(tokscale, 0);

    vm.stopPrank();
  }


  // Legacy registrations are handled by other tests.

  // Test the registration function.
  function test_registerWithScale() external {
    startHoax(deployer);

    assertEq(tokenManager.owner(), deployer);

    tokenManager.registerTokenWithScale(address(token1), remoteToken, 2);
    {
      RemoteToken memory tokrec;
      int8 tokscale;
      (tokrec, tokscale) = tokenManager.getRemoteTokenWithScale(address(token1), remoteChainId);
      assertEq(tokrec.chainId, remoteChainId);
      assertEq(tokrec.token, remoteTokenAddr);
      assertEq(tokrec.tokenManager, remoteTokenManagerAddr);
      assertEq(tokscale, 2);
    }

    tokenManager.removeToken(address(token1), remoteChainId);
    {
      RemoteToken memory tokrec;
      int8 tokscale;
      (tokrec, tokscale) = tokenManager.getRemoteTokenWithScale(address(token1), remoteChainId);
      assertEq(tokrec.chainId, 0);
      assertEq(tokrec.token, address(0));
      assertEq(tokrec.tokenManager, address(0));
      assertEq(tokscale, 0);
    }

    vm.stopPrank();
  }


  function test_scalingUp() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, 2);
    vm.stopPrank();
    startHoax(user);
    vm.expectEmit();
    emit ITestTokenManagerEvents.TransferEvent(address(token1), user,1_000_000 );
    bytes4 acceptSelector = ITokenManager.accept.selector;
    bytes memory expectedCall = abi.encodeWithSelector(acceptSelector,
                                                       CallMetadata(sourceChainId, address(tokenManager)),
                                                       abi.encode(ITokenManagerStructs.AcceptArgs(remoteTokenAddr, user2, 1_000_000_00)));
    vm.expectEmit();
    emit IRelayerEvents.Relayed(remoteChainId, remoteTokenManagerAddr,
                 expectedCall, 1_000_000, 0);
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, user2, 1_000_000);
    vm.stopPrank();
  }

  function test_scalingDown() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, -4);
    vm.stopPrank();
    startHoax(user);
    vm.expectEmit();
    emit ITestTokenManagerEvents.TransferEvent(address(token1), user, 1_230_000 );
    bytes4 acceptSelector = ITokenManager.accept.selector;
    bytes memory expectedCall = abi.encodeWithSelector(acceptSelector,
                                                       CallMetadata(sourceChainId, address(tokenManager)),
                                                       abi.encode(ITokenManagerStructs.AcceptArgs(remoteTokenAddr, user2, 123)));
    vm.expectEmit();
    emit IRelayerEvents.Relayed(remoteChainId, remoteTokenManagerAddr,
                 expectedCall, 1_000_000, 0);
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, user2, 1_230_000);
    vm.stopPrank();
  }


  function test_notPrecise() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, -4);
    vm.stopPrank();
    startHoax(user);
    vm.expectRevert(abi.encodeWithSelector(
        ITokenManagerV4Events.InvalidTokenAmount.selector,
        1_230_001,
        123,
        1_230_000));
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, user2, 1_230_001);
    vm.stopPrank();
  }

  function test_overflow() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, 30);
    vm.stopPrank();
    startHoax(user);
    vm.expectRevert();
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, user2, type(uint256).max-100);
    vm.stopPrank();
  }
}
