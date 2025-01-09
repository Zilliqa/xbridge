// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
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
          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(bscLockAndReleaseOrNativeTokenManagerUpgradeable);
          vm.startBroadcast(deployerPrivateKey);
          address newImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV4());
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall);
          LockAndReleaseOrNativeTokenManagerUpgradeableV4 tokenManagerV4 = LockAndReleaseOrNativeTokenManagerUpgradeableV4(tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("LockAndReleaseOrNative new implementation: %s", address(newImplementation));
          vm.stopBroadcast();
        }
        {
          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(bscTokenManagerMintAndBurn);
          vm.startBroadcast(deployerPrivateKey);
          address newImplementation = address(new MintAndBurnTokenManagerUpgradeableV4());
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall);
          MintAndBurnTokenManagerUpgradeableV4 tokenManagerV4 = MintAndBurnTokenManagerUpgradeableV4(tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("MintAndBurn new implementation: %s", address(newImplementation));
          vm.stopBroadcast();
        }
    }
}
