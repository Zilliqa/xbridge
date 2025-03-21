// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

/*** @title Route tokens from the BSC side.
 */
contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address validator = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", validator);

        vm.startBroadcast(validatorPrivateKey);
        LockAndReleaseTokenManagerUpgradeable zilliqaTokenManager = LockAndReleaseTokenManagerUpgradeable(address(zqLockAndReleaseOrNativeTokenManagerAddress));

        // OK. Now set up the routing ..

        // When zilliqaBridgedERC20 arrives at zilliqaTokenManager, send it to bscERC20 on bscTokenManager
        ITokenManagerStructs.RemoteToken memory sourceBscERC20GasStruct = ITokenManagerStructs.RemoteToken({
         token: address(bscERC20Address),
         tokenManager: address(bscLockProxyTokenManagerAddress),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zqBridgedERC20EVMAddress), sourceBscERC20GasStruct);

        // When zilliqaZRC2 arrives at zilliqaTokenManager, send it to bscBridgedZRC2FromZilliqa on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZRC2 = ITokenManagerStructs.RemoteToken({
         token: address(bscBridgedZRC2Address),
         tokenManager: address(bscLockProxyTokenManagerAddress),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zqZRC2EVMAddress), bridgedZRC2);

        // When ZIL arrives at zilliqaTokenManager, send it to bscBridgedZIL on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZIL = ITokenManagerStructs.RemoteToken({
         token: address(bscBridgedZILAddress),
         tokenManager: address(bscLockProxyTokenManagerAddress),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(0), bridgedZIL);

        // When zilliqaBridgedBNB arrives at zilliqaTokenManager, send it to 0 on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedBNB = ITokenManagerStructs.RemoteToken({
         token: address(0),
         tokenManager: address(bscLockProxyTokenManagerAddress),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zqBridgedBNBEVMAddress), bridgedBNB);
  }
}

