// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ValidatorManagerUpgradeable} from "contracts/core-upgradeable/ValidatorManagerUpgradeable.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";

contract Deployment is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);
        address validator = address(0x250572Ed005BaD64Ff24FbDc0d41875dAF58944f);
        console.log("Validator is %s", validator);

        address[] memory validators = new address[](1);
        validators[0] = owner;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Validator Manager
        address vmImplementation = address(
            new ValidatorManagerUpgradeable{salt: "pol"}()
        );
        bytes memory vmInitCall = abi.encodeWithSelector(
            ValidatorManagerUpgradeable.initialize.selector,
            owner,
            validators
        );
        address vmProxy = address(
            new ERC1967Proxy{salt: "pol"}(vmImplementation, vmInitCall)
        );
        ValidatorManagerUpgradeable validatorManager = ValidatorManagerUpgradeable(
                vmProxy
            );
        console.log(
            "ValidatorManager Deployed: %s, owner is validator: %s, and size %s",
            address(validatorManager),
            validatorManager.isValidator(validators[0]),
            validatorManager.validatorsSize()
        );

        // Deploy Chain Gateway
        address cgImplementation = address(
            new ChainGatewayUpgradeable{salt: "pol"}()
        );
        bytes memory cgInitCall = abi.encodeWithSelector(
            ChainGatewayUpgradeable.initialize.selector,
            address(validatorManager),
            owner
        );
        address cgProxy = address(
            new ERC1967Proxy{salt: "pol"}(cgImplementation, cgInitCall)
        );
        ChainGatewayUpgradeable chainGateway = ChainGatewayUpgradeable(cgProxy);
        console.log(
            "ChainGateway Deployed: %s, with validatorManager %s",
            address(chainGateway),
            address(chainGateway.validatorManager())
        );

        console.log("polChainGatewayAddress = %s;", address(chainGateway));
        console.log("polValidatorManager = %s;", address(validatorManager));

        vm.stopBroadcast();
    }
}
