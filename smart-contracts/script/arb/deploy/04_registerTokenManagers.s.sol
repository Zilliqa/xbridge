// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract registerLockProxy is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);
    // The lock proxy token manager needs to know where its lock proxy is.
    LockProxyTokenManagerUpgradeableV3 lockProxyTokenManager = LockProxyTokenManagerUpgradeableV3(payable(arbLockProxyTokenManager));
    LockAndReleaseOrNativeTokenManagerUpgradeableV3 lockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV3(payable(arbLockAndReleaseOrNativeTokenManagerUpgradeable));
    ChainGatewayUpgradeable chainGateway = ChainGatewayUpgradeable(arbChainGatewayAddress);

    lockProxyTokenManager.setLockProxyData(polLockProxy, polLockProxyProxy);
    chainGateway.register(address(lockProxyTokenManager));
    chainGateway.register(address(lockAndReleaseOrNativeTokenManager));
    vm.stopBroadcast();
  }

}
