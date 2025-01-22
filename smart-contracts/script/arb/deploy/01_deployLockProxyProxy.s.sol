// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockProxyProxy} from "contracts/periphery/LockProxyProxy.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";

contract Deployment is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address owner = vm.addr(deployerPrivateKey);
    address[] memory tokens = new address[](1);
    tokens[0] = 0x1816A0f20bc996F643B1aF078e8D84a0aaBD772A;
    address lockProxy = arbLockProxy;
    vm.startBroadcast(deployerPrivateKey);
    LockProxyProxy lpp = new LockProxyProxy(tokens, owner, lockProxy);
    console.log("arb_lockProxyProxy = %s;", address(lpp));
    vm.stopBroadcast();
  }
}
