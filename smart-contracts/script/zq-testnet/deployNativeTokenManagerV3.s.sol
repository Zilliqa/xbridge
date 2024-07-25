// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {LockAndReleaseOrNativeTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseOrNativeTokenManagerDeployer.sol";
import "forge-std/console.sol";
import "script/testnet_config.s.sol";

contract Deployment is Script, LockAndReleaseOrNativeTokenManagerDeployer,TestnetConfig {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address chainGatewayAddress = zq_chainGateway;
        uint fees = 60 ether; // 60 ZIL

        vm.startBroadcast(deployerPrivateKey);
        LockAndReleaseOrNativeTokenManagerUpgradeableV3 tokenManager =
            deployLatestLockAndReleaseOrNativeTokenManager(chainGatewayAddress, fees);
        console.log(
            "LockAndReleaseOrNativeTokenManager Proxy deployed to %s, with owner %s and gateway %s",
            address(tokenManager),
            tokenManager.owner(),
            tokenManager.getGateway()
        );

        ChainGateway chainGateway = ChainGateway(chainGatewayAddress);
        chainGateway.register(address(tokenManager));

        console.log(
            "TokenManager %s registered to %s ChainGateway: %s",
            address(tokenManager),
            address(chainGateway),
            chainGateway.registered(address(tokenManager))
        );

        vm.stopBroadcast();
    }
}
