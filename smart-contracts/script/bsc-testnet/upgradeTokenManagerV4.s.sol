// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

contract Upgrade is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Signer is %s", owner);

        console.log("Upgrading Mint And Burn token manager");
        {
          // Constants
          address tokenManagerAddress = bscNewMintAndBurnTokenManagerAddress;

          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(
              tokenManagerAddress
                                                                         );
          vm.startBroadcast(deployerPrivateKey);

          address newImplementation = address(
              new MintAndBurnTokenManagerUpgradeableV4()
                                              );
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall
                                        );
          MintAndBurnTokenManagerUpgradeableV4 tokenManagerV4 = MintAndBurnTokenManagerUpgradeableV4(
              tokenManagerAddress);
          console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
          console.log("MintAndBurn New implementation: %s", address(tokenManagerV4));
                      vm.stopBroadcast();
        }
        console.log("Upgrading LockProxyTokenManagerAddress");
        {
          // Constants
          address tokenManagerAddress = bscLockProxyTokenManagerAddress;

          TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(
              tokenManagerAddress
                                                                         );

          vm.startBroadcast(deployerPrivateKey);

          address newImplementation = address(
              new LockProxyTokenManagerUpgradeableV4());
          bytes memory encodedReinitializerCall = "";
          tokenManager.upgradeToAndCall(
              newImplementation,
              encodedReinitializerCall
                                        );
          LockProxyTokenManagerUpgradeableV4 tokenManagerV4 = LockProxyTokenManagerUpgradeableV4(tokenManagerAddress);
               console.log("New pending owner: %s", tokenManagerV4.pendingOwner());
               console.log("LockProxy new implementation: %s", address(tokenManagerV4));
            vm.stopBroadcast();
        }

    }
}
