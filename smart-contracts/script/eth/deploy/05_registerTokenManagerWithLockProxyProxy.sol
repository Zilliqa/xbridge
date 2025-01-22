// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockProxyProxy} from "contracts/periphery/LockProxyProxy.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract registerLockProxy is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);
    // The lock proxy token manager needs to know where its lock proxy is.
    LockProxyTokenManagerUpgradeableV4 lockProxyTokenManager = LockProxyTokenManagerUpgradeableV4(payable(ethLockProxyTokenManager));
    LockProxyProxy lockProxyProxy = LockProxyProxy(payable(ethLockProxyProxy));
    lockProxyProxy.addCaller(address(lockProxyTokenManager));
    vm.stopBroadcast();
  }
}
