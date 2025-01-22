// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(deployerPrivateKey);
        // The other half of these tokens are deployed via the scilla-contracts/scripts/deploy.ts script.

        // Only one of these - native on Zilliqa.
        // Native on Zilliqa
        SwitcheoToken bridgedFromZilliqa = new SwitcheoToken(bscLockProxyAddress, "SCaLeD", "eSCLD", 8);
        console.log(
            "    address public constant bscBridgedScaledTokenAddress = %s", address(bridgedFromZilliqa));
  }
}
