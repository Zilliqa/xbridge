// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import {ChainDispatcherUpgradeable} from "contracts/core-upgradeable/ChainDispatcherUpgradeable.sol";
import {ValidatorManagerUpgradeable} from "contracts/core-upgradeable/ValidatorManagerUpgradeable.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract registerValidators is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);
    ChainDispatcherUpgradeable chainGateway = ChainDispatcherUpgradeable(ethChainGatewayAddress);
    ValidatorManagerUpgradeable validatorManager = ValidatorManagerUpgradeable(chainGateway.validatorManager());
    console.log("validatorManager = %s", address(validatorManager));
    if (!validatorManager.isValidator(primaryValidatorAddress)) {
      console.log("primary validator is not a validator - add it");
      validatorManager.addValidator(primaryValidatorAddress);
    } else {
      console.log("primary validator is a validator");
    }
    if (validatorManager.isValidator(deployerAddress)) {
      console.log("deployer is a validator - remove it");
      validatorManager.removeValidator(deployerAddress);
    } else {
      console.log("deployer is a validator");
    }
    
    vm.stopBroadcast();
  }
}
