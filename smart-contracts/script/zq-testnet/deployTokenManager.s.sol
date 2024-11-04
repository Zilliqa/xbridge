// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import "forge-std/console.sol";


contract Deployment is Script, TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address chainGatewayAddress = zqChainGatewayAddress;

        vm.startBroadcast(deployerPrivateKey);

        address implementation = address(
            new LockAndReleaseTokenManagerUpgradeable()
        );

        bytes memory initializeData = abi.encodeCall(
            LockAndReleaseTokenManagerUpgradeable.initialize,
            chainGatewayAddress
        );

        address proxy = address(
            new ERC1967Proxy(implementation, initializeData)
        );

        LockAndReleaseTokenManagerUpgradeable tokenManager = LockAndReleaseTokenManagerUpgradeable(
                proxy
            );

        console.log(
            "LockAndReleaseTokenManager Proxy deployed to %s, with owner %s and gateway %s",
            address(tokenManager),
            tokenManager.owner(),
            tokenManager.getGateway()
        );
        console.log(
            "    address public constant zqLockAndReleaseTokenManagerAddress = %s", address(tokenManager));

        ChainGateway chainGateway = ChainGateway(chainGatewayAddress);
        chainGateway.register(proxy);

        console.log(
            "TokenManager %s registered to %s ChainGateway: %s",
            address(tokenManager),
            address(chainGateway),
            chainGateway.registered(proxy)
        );

        vm.stopBroadcast();
    }
}
