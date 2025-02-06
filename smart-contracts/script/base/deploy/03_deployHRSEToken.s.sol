// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {MintAndBurnTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/MintAndBurnTokenManagerUpgradeableV5.sol";
import {BridgedTokenV2} from "contracts/periphery/BridgedTokenV2.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import { TokenManagerDeployerUtil } from "script/tokenManagerDeployerUtil.s.sol";

contract deployHRSEToken is Script, MainnetConfig, TokenManagerDeployerUtil {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);
    MintAndBurnTokenManagerUpgradeableV5 mintAndBurnTokenManager = MintAndBurnTokenManagerUpgradeableV5(baseMintAndBurnTokenManagerUpgradeable);
    BridgedTokenV2 bridged = mintAndBurnTokenManager.deployToken("The Winners Circle", "HRSE", 18, address(zqHRSETokenAddress), zilLockAndReleaseOrNativeTokenManagerUpgradeable, zilChainId);
    console.log("HRSE base side is %s", address(bridged));
    vm.stopBroadcast();
  }
}
