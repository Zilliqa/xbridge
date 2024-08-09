// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

contract Transfer is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        address tokenManagerAddress = zqLockAndReleaseTokenManagerAddress;
        address tokenAddress = zqLegacyTestTokenAddress;

        uint remoteChainId = bscChainId;
        address remoteRecipient = owner;
        uint amount = 10;

        ERC20 token = ERC20(tokenAddress);
        LockAndReleaseTokenManagerUpgradeable tokenManager = LockAndReleaseTokenManagerUpgradeable(
                tokenManagerAddress
            );

        vm.startBroadcast(deployerPrivateKey);
        console.log(
            "Owner Balance: %d, TokenManagerBalance %d, %s",
            token.balanceOf(owner),
            token.balanceOf(tokenManagerAddress),
            token.name()
        );

        token.approve(tokenManagerAddress, amount);
        tokenManager.transfer(
            tokenAddress,
            remoteChainId,
            remoteRecipient,
            amount
        );

        console.log(
            "New Owner Balance: %d, TokenManagerBalance %d",
            token.balanceOf(owner),
            token.balanceOf(tokenManagerAddress)
        );
        vm.stopBroadcast();
    }
}
