// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { ZRC2ProxyForZRC2 } from "test/zilbridge/tokens/zrc2erc20/ZRC2ProxyForZRC2.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

/*** @title Deploy an ERC20 proxy for our ZRC2, so we can set routing with it.
 */
contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address validator = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", validator);
        vm.startBroadcast(validatorPrivateKey);
        {
          ZRC2ProxyForZRC2 proxy = new ZRC2ProxyForZRC2(zqBridgedERC20Address);
          console.log(
              "    address public constant zqBridgedERC20EVMAddress = %s", address(proxy));
        }
        {
          ZRC2ProxyForZRC2 proxy = new ZRC2ProxyForZRC2(zqBridgedBNBAddress);
          console.log(
              "    address public constant zqBridgedBNBEVMAddress = %s", address(proxy));
        }
        {
          ZRC2ProxyForZRC2 proxy = new ZRC2ProxyForZRC2(zqZRC2Address);
          console.log(
              "    address public constant zqZRC2EVMAddress = %s", address(proxy));
        }
  }
}
