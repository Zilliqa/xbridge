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
        address owner = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(validatorPrivateKey);
        LockAndReleaseTokenManagerUpgradeable zilliqaTokenManager = LockAndReleaseTokenManagerUpgradeable(zqLockAndReleaseOrNativeTokenManagerAddress);
        LockProxyTokenManagerUpgradeable bscTokenManager = LockProxyTokenManagerUpgradeable(bscLockProxyTokenManagerAddress);

        // OK. Now set up the routing ..

        // When bscERC20 arrives at bscTokenManager, send it to zilliqaBridgedERC20 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory sourceBscERC20GasStruct = ITokenManagerStructs.RemoteToken({
         token: address(zqBridgedERC20EVMAddress),
         tokenManager: address(zilliqaTokenManager),
         chainId: zqChainId});
        bscTokenManager.registerToken(address(bscERC20Address), sourceBscERC20GasStruct);

        // When bscBridgedZRC2FromZilliqa arrives at bscTokenManager, send it to zilliqaZRC2 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZRC2 = ITokenManagerStructs.RemoteToken({
         token: address(zqZRC2EVMAddress),
         tokenManager: address(zilliqaTokenManager),
         chainId: zqChainId});
        bscTokenManager.registerToken(address(bscBridgedZRC2Address), bridgedZRC2);

        // When bscBridgedZIL arrives at bscTokenManager, send it to 0 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZIL = ITokenManagerStructs.RemoteToken({
         token: address(0),
         tokenManager: address(zilliqaTokenManager),
         chainId: zqChainId});
        bscTokenManager.registerToken(address(bscBridgedZILAddress), bridgedZIL);

        // When BNB arrives at bscTokenManager, sent it to zilliqaBridgedBNB on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedBNB = ITokenManagerStructs.RemoteToken({
         token: address(zqBridgedBNBEVMAddress),
         tokenManager: address(zilliqaTokenManager),
         chainId: zqChainId});
        bscTokenManager.registerToken(address(0), bridgedBNB);
  }
}

