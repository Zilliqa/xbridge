// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import "forge-std/console.sol";
import "script/mainnetConfig.s.sol";

contract GetValidators is Script, MainnetConfig {
  function run() external {
    ChainGateway cg = ChainGateway(bscChainGatewayAddress);
    ValidatorManager vm = ValidatorManager(cg.validatorManager());
    console.log("Validator manager = %x", address(vm));
    address[] memory validators = vm.getValidators();
    for (uint256 i =0 ;i < validators.length; ++i) {
      console.log("validator[%d] = %x", i, validators[i]);
    }
  }
}
