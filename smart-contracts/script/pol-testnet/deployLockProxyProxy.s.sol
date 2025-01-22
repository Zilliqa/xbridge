// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockProxyProxy} from "contracts/periphery/LockProxyProxy.sol";
import "forge-std/console.sol";

contract Deployment is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address owner = vm.addr(deployerPrivateKey);
    address[] memory tokens = new address[](1);
    tokens[0] = 0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17;
    address lockProxy = 0x43138036d1283413035B8eca403559737E8f7980;
    vm.startBroadcast(deployerPrivateKey);
    LockProxyProxy lpp = new LockProxyProxy(tokens, owner, lockProxy);
    console.log("pol_lockProxyProxy = %s;", address(lpp));
    vm.stopBroadcast();
  }
}
