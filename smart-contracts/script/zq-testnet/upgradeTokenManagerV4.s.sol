// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

contract Upgrade is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Signer is %s", owner);

        console.log("Upgrading LockAndReleaseTokenManager .. ");
        {
          // Constants
          address payable tokenManagerAddress = payable(zqLockAndReleaseTokenManagerAddress);

          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(
              tokenManagerAddress
                                                                         );
          vm.startBroadcast(deployerPrivateKey);

          address newImplementation = address(
              new LockAndReleaseOrNativeTokenManagerUpgradeableV4()
                                              );
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall
                                        );
          LockAndReleaseOrNativeTokenManagerUpgradeableV4 tokenManagerV4 = LockAndReleaseOrNativeTokenManagerUpgradeableV4(
              tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("LockAndRelease New implementation: %s", address(newImplementation));
                      vm.stopBroadcast();
        }
        console.log("Upgrading LockAndReleaseOrNativeTokenManager .. ");
        {
          // Constants
          address payable tokenManagerAddress = payable(zqLockAndReleaseOrNativeTokenManagerAddress);

          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(
              tokenManagerAddress
                                                                         );
          vm.startBroadcast(deployerPrivateKey);

          address newImplementation = address(
              new LockAndReleaseOrNativeTokenManagerUpgradeableV4()
                                              );
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall
                                        );
          LockAndReleaseOrNativeTokenManagerUpgradeableV4 tokenManagerV4 = LockAndReleaseOrNativeTokenManagerUpgradeableV4(
              tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("LockAndReleaseOrNative New implementation: %s", address(newImplementation));
                      vm.stopBroadcast();
        }

    }
}
