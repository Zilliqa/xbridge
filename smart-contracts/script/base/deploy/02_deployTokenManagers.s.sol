// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {MintAndBurnTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/MintAndBurnTokenManagerUpgradeableV5.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import { TokenManagerDeployerUtil } from "script/tokenManagerDeployerUtil.s.sol";

contract deployTokenManagers is Script, MainnetConfig, TokenManagerDeployerUtil {
  function run() external {
    // 0.00025 ZIL
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    uint fees = 0.00025 ether;
    vm.startBroadcast(deployerPrivateKey);
    LockAndReleaseOrNativeTokenManagerUpgradeableV5 lockAndReleaseOrNativeTokenManager = deployLockAndReleaseOrNativeTokenManagerV5(baseChainGatewayAddress, fees);
    MintAndBurnTokenManagerUpgradeableV5 mintAndBurnTokenManager = deployMintAndBurnTokenManagerV5(baseChainGatewayAddress, fees);
    console.log(" baseLockAndReleaseOrNativeTokenManagerUpgradeable = %s;", address(lockAndReleaseOrNativeTokenManager));
    console.log(" baseMintAndBurnTokenManagerUpgradeable = %s;", address(mintAndBurnTokenManager));
    // Register them with the chain gateway
    ChainGatewayUpgradeable chainGateway = ChainGatewayUpgradeable(baseChainGatewayAddress);
    chainGateway.register(address(lockAndReleaseOrNativeTokenManager));
    chainGateway.register(address(mintAndBurnTokenManager));
    vm.stopBroadcast();
  }
}
