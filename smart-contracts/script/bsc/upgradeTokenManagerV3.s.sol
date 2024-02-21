// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MintAndBurnTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/MintAndBurnTokenManagerUpgradeableV3.sol";
import "forge-std/console.sol";

contract Upgrade is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TEST");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Signer is %s", owner);

        // Constants
        address tokenManagerAddress = 0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23;

        TokenManagerUpgradeable tokenManager = TokenManagerUpgradeable(
            tokenManagerAddress
        );

        vm.startBroadcast(deployerPrivateKey);

        address newImplementation = address(
            new MintAndBurnTokenManagerUpgradeableV3()
        );
        bytes memory encodedReinitializerCall = "";
        tokenManager.upgradeToAndCall(
            newImplementation,
            encodedReinitializerCall
        );

        MintAndBurnTokenManagerUpgradeableV3 tokenManagerV3 = MintAndBurnTokenManagerUpgradeableV3(
                tokenManagerAddress
            );
        console.log("New pending owner: %s", tokenManagerV3.pendingOwner());

        vm.stopBroadcast();
    }
}
