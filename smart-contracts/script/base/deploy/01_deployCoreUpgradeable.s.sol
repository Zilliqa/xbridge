// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ValidatorManagerUpgradeable} from "contracts/core-upgradeable/ValidatorManagerUpgradeable.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import "forge-std/console.sol";

contract Deployment is Script, MainnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);
        address validator = address(primaryValidatorAddress);
        console.log("Validator is %s", validator);

        address[] memory validators = new address[](1);
        validators[0] = validator;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Validator Manager
        address vmImplementation = address(
            new ValidatorManagerUpgradeable{salt: "base"}()
        );
        bytes memory vmInitCall = abi.encodeWithSelector(
            ValidatorManagerUpgradeable.initialize.selector,
            owner,
            validators
        );
        address vmProxy = address(
            new ERC1967Proxy{salt: "base"}(vmImplementation, vmInitCall)
        );
        ValidatorManagerUpgradeable validatorManager = ValidatorManagerUpgradeable(
                vmProxy
            );
        console.log(
            "ValidatorManager owner %s",
            address(validatorManager.owner()));
        console.log(
            "ValidatorManager Deployed: %s, validator: %s, and size %s",
            address(validatorManager),
            validatorManager.isValidator(validators[0]),
            validatorManager.validatorsSize()
        );

        // Deploy Chain Gateway
        address cgImplementation = address(
            new ChainGatewayUpgradeable{salt: "base"}()
        );
        bytes memory cgInitCall = abi.encodeWithSelector(
            ChainGatewayUpgradeable.initialize.selector,
            address(validatorManager),
            owner
        );
        address cgProxy = address(
            new ERC1967Proxy{salt: "base"}(cgImplementation, cgInitCall)
        );
        ChainGatewayUpgradeable chainGateway = ChainGatewayUpgradeable(cgProxy);
        console.log(
            "ChainGateway Deployed: %s, with validatorManager %s",
            address(chainGateway),
            address(chainGateway.validatorManager())
        );

        console.log("baseChainGatewayAddress = %s;", address(chainGateway));
        console.log("baseValidatorManager = %s;", address(validatorManager));

        vm.stopBroadcast();
    }
}
