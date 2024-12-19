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
    tokens[0] = 0xb1E6F8820826491FCc5519f84fF4E2bdBb6e3Cad;
    address lockProxy = 0xb5D4f343412dC8efb6ff599d790074D0f1e8D430;
    vm.startBroadcast(deployerPrivateKey);
    LockProxyProxy lpp = new LockProxyProxy(tokens, owner, lockProxy);
    console.log("BSC LockProxyProxy deployed at %s", address(lockProxy));
    vm.stopBroadcast();
  }
}
