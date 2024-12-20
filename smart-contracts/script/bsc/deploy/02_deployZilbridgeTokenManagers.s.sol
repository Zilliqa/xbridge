// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import { TokenManagerDeployerUtil } from "script/tokenManagerDeployerUtil.s.sol";

contract deployZilbridgeTokenManagers is Script, MainnetConfig, TokenManagerDeployerUtil {
  function run() external {
    // 0.00025 ZIL
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    uint fees = 0.00025 ether;
    vm.startBroadcast(deployerPrivateKey);
    LockAndReleaseOrNativeTokenManagerUpgradeableV3 lockAndReleaseOrNativeTokenManager = deployLockAndReleaseOrNativeTokenManager(bscChainGatewayAddress, fees);
    LockProxyTokenManagerUpgradeableV3 lockProxyTokenManager = deployLockProxyTokenManager(bscChainGatewayAddress, fees);
    console.log(" bscLockAndReleaseOrNativeTokenManagerUpgradeable = %s;", address(lockAndReleaseOrNativeTokenManager));
    console.log(" bscLockProxyTokenManager = %s;", address(lockProxyTokenManager));
    vm.stopBroadcast();
  }
}
