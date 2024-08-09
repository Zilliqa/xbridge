pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {ITokenManagerStructs, ITokenManager} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ZRC2ProxyForZRC2} from "test/zilbridge/tokens/zrc2erc20/ZRC2ProxyForZRC2.sol";
import "forge-std/console.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {IRelayer, Relayer, CallMetadata} from "contracts/core/Relayer.sol";
import {Registry} from "contracts/core/Registry.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
    //        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");

        address validator = vm.addr(validatorPrivateKey);
        vm.startBroadcast(validatorPrivateKey);
        console.log("I am %s", validator);
        console.log("Token manager at %s", zqLockAndReleaseOrNativeTokenManagerAddress);
        console.log("ChainGateway %s", zqChainGatewayAddress);
        ChainGateway chainGateway = ChainGateway(zqChainGatewayAddress);
        chainGateway.register(address(zqLockAndReleaseOrNativeTokenManagerAddress));
        console.log(
            "TokenManager %s registered to %s ChainGateway: %s",
            address(zqLockAndReleaseOrNativeTokenManagerAddress),
            address(chainGateway),
            chainGateway.registered(address(zqLockAndReleaseOrNativeTokenManagerAddress))
        );

        Relayer relayer = Relayer(zqChainGatewayAddress);
        bool amRegistered = relayer.registered(zqLockAndReleaseOrNativeTokenManagerAddress);
        console.log("isRegistered %d", amRegistered);
  }
}
