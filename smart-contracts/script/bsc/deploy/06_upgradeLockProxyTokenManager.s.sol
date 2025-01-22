// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
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
          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(bscLockProxyTokenManager);
          vm.startBroadcast(deployerPrivateKey);
          address newImplementation = address(new LockProxyTokenManagerUpgradeableV4());
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall);
          address payable tokenManagerAddress = payable(address(tokenManager));
          LockProxyTokenManagerUpgradeableV4 tokenManagerV4 = LockProxyTokenManagerUpgradeableV4(tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("LockAndReleaseOrNative new implementation: %s", address(newImplementation));
          vm.stopBroadcast();
        }
    }
}
