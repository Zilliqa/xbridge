// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseTokenManagerUpgradeableV3.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

contract Unpause is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Deployer is %s", owner);

        address tokenManagerAddress = zqLockAndReleaseTokenManagerAddress;

        vm.startBroadcast(deployerPrivateKey);
        {
          LockAndReleaseTokenManagerUpgradeableV3 tokenManager = LockAndReleaseTokenManagerUpgradeableV3(
                tokenManagerAddress
                                                                                                         );
          tokenManager.unpause();
          console.log(
              "TokenManager %s, paused: %s",
              tokenManagerAddress,
              tokenManager.paused()
                      );
        }
        {
          LockAndReleaseTokenManagerUpgradeableV3 tokenManager = LockAndReleaseTokenManagerUpgradeableV3(
              zqLockAndReleaseOrNativeTokenManagerAddress
                                                                                                         );
          tokenManager.unpause();
          console.log(
              "TokenManager %s, paused: %s",
              address(tokenManager),
              tokenManager.paused()
                      );
        }
        vm.stopBroadcast();
    }
}
