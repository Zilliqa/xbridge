pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
        address validator = vm.addr(validatorPrivateKey);
        address recipient = vm.envAddress("ZILBRIDGE_TEST_ADDRESS");
        uint256 amount = vm.envUint("ZILBRIDGE_TEST_AMOUNT");
        console.log("Owner is %s", validator);
        vm.startBroadcast(validatorPrivateKey);
        ERC20 theContract = ERC20(zqZRC2EVMAddress);
        theContract.transfer( recipient, amount );
  }

}
