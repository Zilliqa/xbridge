// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import { TokenManagerDeployerUtilV4 } from "script/tokenManagerDeployerUtilV4.s.sol";

contract deployZilbridgeTokenManagers is Script, MainnetConfig, TokenManagerDeployerUtilV4 {
  function run() external {
    // 0.00025 ZIL
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    uint fees = 0.00025 ether;
    vm.startBroadcast(deployerPrivateKey);
    LockAndReleaseOrNativeTokenManagerUpgradeableV4 lockAndReleaseOrNativeTokenManager = deployLockAndReleaseOrNativeTokenManager(ethChainGatewayAddress, fees);
    LockProxyTokenManagerUpgradeableV4 lockProxyTokenManager = deployLockProxyTokenManager(ethChainGatewayAddress, fees);
    console.log(" ethLockAndReleaseOrNativeTokenManagerUpgradeable = %s;", address(lockAndReleaseOrNativeTokenManager));
    console.log(" ethLockProxyTokenManager = %s;", address(lockProxyTokenManager));
    vm.stopBroadcast();
  }
}
