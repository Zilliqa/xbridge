// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";

/*** @notice this script wires up the token manager for the zilbridge tests on zq_testnet. The corresponding code on Zilliqa is
 *   in a file of the same name in zq-testnet.
 */
contract Deployment is Script {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
    address validator = vm.addr(deployerPrivateKey);

    // This is the LockAndReleaseOrNativeTokenManager token manager on zq-testnet.
    address tokenManager = 0xBe90AB2cd65E207F097bEF733F8D239A59698b8A;

    // Native on BSC, bridged to Zilliqa
    address nativeOnBSC  = 0x43b1e04b72Aca6aA54c49f540Ef8ea3970d2A541;
    
    

    
    // Native on BSC testnet, bridged to Zilliqa testnet.
    address tokenContract = address(0x00839901f1e39De75301667C6bBbF7fB556Ea2510E);
    // BSC, bridged to Zilliqa.
    address bscBridgedToZilliqa = address(0x0006852e68A3c24917cfA4C2dbDaE4B308C69aDA5e);
    // Native ZRC2 on Zilliqa, bridged to BSC.
    address zrc2OnZilliqua = address(0x00155F0f76b660290F2F00Bb5674b80eDC208bF2e6);

  }
}
