// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ValidatorManagerUpgradeable} from "contracts/core-upgradeable/ValidatorManagerUpgradeable.sol";
import {ChainGatewayUpgradeable} from "contracts/core-upgradeable/ChainGatewayUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import "forge-std/console.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

contract Deployment is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        address[] memory validators = new address[](1);
        address tokenManager = bscNewMintAndBurnTokenManagerAddress;
        validators[0] = owner;

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Validator Manager
        address vmImplementation = address(
            new ValidatorManagerUpgradeable{salt: "zilliqa"}()
        );
        bytes memory vmInitCall = abi.encodeWithSelector(
            ValidatorManagerUpgradeable.initialize.selector,
            owner,
            validators
        );
        address vmProxy = address(
            new ERC1967Proxy{salt: "zilliqa"}(vmImplementation, vmInitCall)
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
        console.log(
            "    address public constant bscValidatorManagerAddress = %s", address(validatorManager));

        // Deploy Chain Gateway
        address cgImplementation = address(
            new ChainGatewayUpgradeable{salt: "zilliqa"}()
        );
        bytes memory cgInitCall = abi.encodeWithSelector(
            ChainGatewayUpgradeable.initialize.selector,
            address(validatorManager),
            owner
        );
        address cgProxy = address(
            new ERC1967Proxy{salt: "zilliqa"}(cgImplementation, cgInitCall)
        );
        ChainGatewayUpgradeable chainGateway = ChainGatewayUpgradeable(cgProxy);
        console.log(
            "ChainGateway Deployed: %s, with validatorManager %s",
            address(chainGateway),
            address(chainGateway.validatorManager())
        );
        console.log(
            "    address public constant bscChainGatewayAddress = %s", address(chainGateway));

        // Register TokenManager to ChainGateway
        chainGateway.register(tokenManager);
        console.log(
            "TokenManager %s, registered to %s ChainGateway: %s",
            address(tokenManager),
            address(chainGateway),
            chainGateway.registered(tokenManager)
        );

        vm.stopBroadcast();
    }
}
