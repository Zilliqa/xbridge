// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester, Vm} from "test/Tester.sol";
import {ITokenManagerStructs, TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import {CallMetadata, IRelayerEvents} from "contracts/core/Relayer.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {TestToken} from "test/Helpers.sol";
import {LockAndReleaseOrNativeTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseOrNativeTokenManagerDeployer.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import { ZilBridgeFixture } from "test/zilbridge/DeployZilBridge.t.sol";
import { MockLockProxy } from "./MockLockProxy.sol";
import { ZilBridgeTokenBridgeIntegrationFixture } from "./ZilBridgeTokenIntegrationFixture.t.sol";
import { TetherToken } from "./tokens/Tether.sol";

contract TokenManagerTetherTest is Tester, IRelayerEvents, LockAndReleaseOrNativeTokenManagerDeployer {
  using MessageHashUtils for bytes;
  Vm.Wallet validatorWallet = vm.createWallet(1);
  address validator = validatorWallet.addr;
  address[] validators = [ validator ];
  Vm.Wallet sourceUserWallet = vm.createWallet(2);
  address sourceUser = sourceUserWallet.addr;
  address remoteUser = vm.addr(3);
  Vm.Wallet deployerWallet = vm.createWallet(10);
  address deployer = deployerWallet.addr;
  // Totally random address.
  address remoteTokenManager = vm.addr(4);
  address remoteToken = vm.addr(5);
  uint remoteChainId = 42;
  
  LockAndReleaseOrNativeTokenManagerUpgradeableV5 tokenManager;
  TetherToken tetherToken;
  ChainGateway chainGateway;
  ValidatorManager validatorManager;
  uint fees = 0.0025 ether;

  uint AMOUNT = 600;
  uint SUPPLY = 1_000;
  
    function setUp() external {
      vm.startPrank(deployer);
      validatorManager = new ValidatorManager(deployer);
      validatorManager.addValidator(validator);
      console.log("Validator address is %s", address(validator));
      chainGateway = new ChainGateway(address(validatorManager), deployer);
      tetherToken = new TetherToken(1_000_000, "Tether", "THTR", 4);
      tetherToken.transfer(sourceUser, SUPPLY);
      tokenManager = deployLatestLockAndReleaseOrNativeTokenManager(address(chainGateway), fees);
      chainGateway.register(address(tokenManager));

      ITokenManagerStructs.RemoteToken memory routingStruct = ITokenManagerStructs.RemoteToken( {
       token: remoteToken,
       tokenManager: remoteTokenManager,
       chainId: remoteChainId });
      tokenManager.registerToken(address(tetherToken), routingStruct);
      vm.stopPrank();
    }

    function test_sender() external {
      startHoax(sourceUser);
      tetherToken.approve(address(tokenManager), AMOUNT);
      bytes memory data = abi.encodeWithSelector(
          TokenManagerUpgradeable.accept.selector,
          CallMetadata(block.chainid, address(tokenManager)),
          abi.encode(ITokenManagerStructs.AcceptArgs(address(remoteToken), remoteUser, AMOUNT)));
      vm.expectEmit();
      emit IRelayerEvents.Relayed(
          remoteChainId,
          address(remoteTokenManager),
          data,
          1_000_000, 0);
      console.log("balance ", address(this).balance);
      tokenManager.transfer{value: fees}( address(tetherToken), remoteChainId, remoteUser, AMOUNT);
      assertEq(tetherToken.balanceOf(address(tokenManager)), AMOUNT);
      assertEq(tetherToken.balanceOf(sourceUser), 0);
      assertEq(address(tokenManager).balance, fees);
      vm.stopPrank();
    }

    function test_receiver() external {
      startHoax(sourceUser);
      tetherToken.transfer(address(tokenManager), AMOUNT);
      vm.stopPrank();
      startHoax(validator);
      assertEq(tetherToken.balanceOf(sourceUser), SUPPLY-AMOUNT);
      assertEq(tetherToken.balanceOf(address(tokenManager)), AMOUNT);
      bytes memory data = abi.encodeWithSelector(
          TokenManagerUpgradeable.accept.selector,
          CallMetadata(remoteChainId, remoteTokenManager),
          abi.encode(ITokenManagerStructs.AcceptArgs(address(tetherToken), sourceUser, AMOUNT)));
      bytes[] memory signatures = new bytes[](1);
      signatures[0] = sign(validatorWallet,
                           abi.encode(remoteChainId, block.chainid, address(tokenManager), data, 1_000_000, 0).toEthSignedMessageHash());
      chainGateway.dispatch(remoteChainId,
                            address(tokenManager),
                            data,
                            1_000_000, 0, signatures);
      assertEq(tetherToken.balanceOf(sourceUser), AMOUNT);
      assertEq(tetherToken.balanceOf(address(tokenManager)), 0);
      vm.stopPrank();
    }
}

