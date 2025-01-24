// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract Update is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address owner = vm.addr(deployerPrivateKey);
    console.log("Deployer is %s", owner);

    vm.startBroadcast(deployerPrivateKey);
    Ownable2StepUpgradeable legacyTokenManager = Ownable2StepUpgradeable(zilLockAndReleaseTokenManagerDoNotUseForZilbridge);
    address currentOwner = legacyTokenManager.owner();
    console.log("Owner is %s", currentOwner);
    address pendingOwner = legacyTokenManager.pendingOwner();
    console.log("pendingOwner is %s", pendingOwner);
    legacyTokenManager.acceptOwnership();
  }
}

