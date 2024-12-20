// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {UnrestrictedLockProxyProxy} from "contracts/periphery/UnrestrictedLockProxyProxy.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract Deployment is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address owner = vm.addr(deployerPrivateKey);
    address lockProxy = zilLockProxy;
    vm.startBroadcast(deployerPrivateKey);
    UnrestrictedLockProxyProxy lpp = new UnrestrictedLockProxyProxy(owner, lockProxy);
    console.log("zilUnrestrictedLockProxyProxy = %s;", address(lpp));
    vm.stopBroadcast();
  }
}
