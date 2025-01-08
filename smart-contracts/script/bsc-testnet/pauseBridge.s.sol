// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/MintAndBurnTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";


contract Pause is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Deployer is %s", owner);

        address tokenManagerAddress = bscNewMintAndBurnTokenManagerAddress;

        vm.startBroadcast(deployerPrivateKey);
        {
          MintAndBurnTokenManagerUpgradeableV3 tokenManager = MintAndBurnTokenManagerUpgradeableV3(
                tokenManagerAddress
            );
        tokenManager.pause();
        console.log(
            "TokenManager %s, paused: %s",
            tokenManagerAddress,
            tokenManager.paused()
        );
        }
        {
          LockProxyTokenManagerUpgradeableV3 tokenManager = LockProxyTokenManagerUpgradeableV3(
              bscLockProxyTokenManagerAddress
            );
          tokenManager.pause();
          console.log(
              "TokenManager %s, paused: %s",
              tokenManagerAddress,
              tokenManager.paused()
                      );
        }
        vm.stopBroadcast();
    }
}
