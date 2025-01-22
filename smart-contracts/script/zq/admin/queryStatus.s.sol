// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {ChainDispatcherUpgradeable} from "contracts/core-upgradeable/ChainDispatcherUpgradeable.sol";
import {ValidatorManagerUpgradeable} from "contracts/core-upgradeable/ValidatorManagerUpgradeable.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract Update is Script, MainnetConfig {
  function run() public {
    ChainGateway gateway = ChainGateway(zilChainGatewayAddress);
    LockAndReleaseOrNativeTokenManagerUpgradeableV4 tokenMgr = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(zilLockAndReleaseOrNativeTokenManagerUpgradeable));
    ChainDispatcherUpgradeable chainDispatcher = ChainDispatcherUpgradeable(zilChainGatewayAddress);
    ValidatorManagerUpgradeable validatorManager = ValidatorManagerUpgradeable(chainDispatcher.validatorManager());

    console.log("Chain gateway is %s", address(gateway));
    address owner = gateway.owner();
    console.log("Chain gateway owner is %s", owner);
    console.log("Token manager is %s", address(tokenMgr));
    bool registered = gateway.registered(address(tokenMgr));
    console.log("Registered ? ", registered);
    console.log("validatorManager = %s", address(validatorManager));
    if (!validatorManager.isValidator(primaryValidatorAddress)) {
      console.log("primary validator is not a validator - add it");
    }
    if (validatorManager.isValidator(deployerAddress)) {
      console.log("deployer is a validator - remove it");
    }
  }
}
