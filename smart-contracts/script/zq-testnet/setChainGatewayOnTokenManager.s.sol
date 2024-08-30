// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseTokenManagerUpgradeableV3.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

contract Update is TestnetConfig,Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Deployer is %s", owner);

        address newChainGateway = zqChainGatewayAddress;
        address tokenManagerAddress = zqLockAndReleaseTokenManagerAddress;
        address nativeTokenManagerAddress = zqLockAndReleaseOrNativeTokenManagerAddress;

        vm.startBroadcast(deployerPrivateKey);
        LockAndReleaseTokenManagerUpgradeableV3 tokenManager = LockAndReleaseTokenManagerUpgradeableV3(
                tokenManagerAddress
            );
        tokenManager.setGateway(newChainGateway);
        console.log(
            "LockAndReleaseTokenManager %s, newChainGateway: %s",
            tokenManagerAddress,
            tokenManager.getGateway()
        );
        LockAndReleaseOrNativeTokenManagerUpgradeableV3 nativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV3(
            payable(nativeTokenManagerAddress)
            );
        nativeTokenManager.setGateway(newChainGateway);
        console.log(
            "NativeLockAndReleaseTokenManager %s, newChainGateway: %s",
            nativeTokenManagerAddress,
            nativeTokenManager.getGateway()
        );

        vm.stopBroadcast();
    }
}
