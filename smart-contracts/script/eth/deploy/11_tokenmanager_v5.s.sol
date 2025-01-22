// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import { TokenManagerDeployerUtil } from "script/tokenManagerDeployerUtil.s.sol";


contract Upgrade is Script, MainnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Signer is %s", owner);

        // Constants
        {
          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(ethLockAndReleaseOrNativeTokenManagerUpgradeable);
          vm.startBroadcast(deployerPrivateKey);
          address newImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV5());
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall);
          address payable tokenManagerAddress = payable(address(tokenManager));
          LockAndReleaseOrNativeTokenManagerUpgradeableV5 tokenManagerV5 = LockAndReleaseOrNativeTokenManagerUpgradeableV5(tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV5.pendingOwner());
          console.log("LockAndReleaseOrNative new implementation: %s", address(newImplementation));
          vm.stopBroadcast();
        }
    }
}
