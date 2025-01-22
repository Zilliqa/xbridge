// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockProxyProxy} from "contracts/periphery/LockProxyProxy.sol";
import "forge-std/console.sol";

contract Deployment is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address owner = vm.addr(deployerPrivateKey);
    address[] memory tokens = new address[](5);
    tokens[0] = 0x6EeB539D662bB971a4a01211c67CB7f65B09b802;
    tokens[1] = 0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A;
    tokens[2] = 0xBd636FFfbF349A4479db315c585E823164cF58F0;
    tokens[3] = 0x0c7c5b92893A522952EB4c939aA24B65FF910C48;
    tokens[4] = 0xf7030C3f43b85874ae12B57F44cd682196568b47;
    address lockProxy = 0x9a016Ce184a22DbF6c17daA59Eb7d3140DBd1c54;
    vm.startBroadcast(deployerPrivateKey);
    LockProxyProxy lpp = new LockProxyProxy(tokens, owner, lockProxy);
    console.log("eth_lockProxyProxy = %s;", address(lpp));
    vm.stopBroadcast();
  }
}
