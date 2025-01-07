// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {Tester} from "test/Tester.sol";
import {TokenManagerUpgradeableV4, ITokenManagerV4Events} from "contracts/periphery/TokenManagerV4/TokenManagerUpgradeableV4.sol";
import {ITokenManager, ITokenManagerFees, ITokenManagerStructs, ITokenManagerEvents} from "contracts/periphery/TokenManagerV2/TokenManagerUpgradeableV2.sol";
import {ITokenManagerFeesEvents} from "contracts/periphery/TokenManagerV2/TokenManagerFees.sol";
import {IRelayer} from "contracts/core/Relayer.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestToken} from "test/Helpers.sol";
import { TestTokenManagerDeployer, TestTokenManagerUpgradeableV4 } from "test/periphery/TokenManagerDeployers/TestTokenManagerDeployer.sol";


contract TokenManagerUpgradeableV4Tests is Tester, ITokenManagerStructs, ITokenManagerEvents, ITokenManagerV4Events, TestTokenManagerDeployer {
  address deployer = vm.addr(1);
  address user = vm.createWallet("user").addr;
  uint fees = 0.1 ether;
  TokenManagerUpgradeableV4 tokenManager;
  TestToken token1;
  address remoteTokenAddr = vm.createWallet("remoteToken").addr;
  address remoteTokenManagerAddr = vm.createWallet("remoteTokenManager").addr;
  uint remoteChainId = 101;
  RemoteToken remoteToken =
      RemoteToken({
       token: remoteTokenAddr,
       tokenManager: remoteTokenManagerAddr,
       chainId: remoteChainId
        });
  uint transferAmount = 10 ether;

  event TransferEvent(address indexed token, address indexed from, uint indexed amount);
  event AcceptEvent(address indexed token, address indexed from, uint indexed amount);

  
  function setUp() external {
    vm.startPrank(deployer);
    tokenManager = deployTestTokenManagerV4(fees);
    token1 = new TestToken(transferAmount);
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

  function test_scaling() external {
    startHoax(deployer);
    tokenManager.registerTokenWithScale(address(token1), remoteToken, 2);
    vm.stopPrank();
    startHoax(user);
    vm.expectEmit();
    emit TransferEvent(address(token1), user,1_000_000 );
    tokenManager.transfer{value: fees}(address(token1), remoteChainId, remoteTokenAddr, 1_000_000);
    vm.stopPrank();
  }
  
}
