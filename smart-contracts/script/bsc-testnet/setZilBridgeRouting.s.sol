// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import { TestnetConfig } from "script/testnet_config.s.sol";

/*** @title Route tokens from the BSC side.
 */
contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", owner);

        // The BSC testnet chain id
        uint bscChainId = 97;
        // Zilliqa chain id
        uint zilliqaChainId = 33101;

        vm.startBroadcast(validatorPrivateKey);
        LockAndReleaseTokenManagerUpgradeable zilliqaTokenManager = LockAndReleaseTokenManagerUpgradeable(zq_lockAndReleaseOrNativeTokenManager);
        LockProxyTokenManagerUpgradeable bscTokenManager = LockProxyTokenManagerUpgradeable(bsc_zilBridgeTokenManager);

        // OK. Now set up the routing ..

        // When bscERC20 arrives at bscTokenManager, send it to zilliqaBridgedERC20 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory sourceBscERC20GasStruct = ITokenManagerStructs.RemoteToken({
         token: address(zq_bridged_erc20_evm),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bsc_erc20), sourceBscERC20GasStruct);

        // When bscBridgedZRC2FromZilliqa arrives at bscTokenManager, send it to zilliqaZRC2 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZRC2 = ITokenManagerStructs.RemoteToken({
         token: address(zq_zrc2_evm),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bsc_bridgedzrc2), bridgedZRC2);

        // When bscBridgedZIL arrives at bscTokenManager, send it to 0 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZIL = ITokenManagerStructs.RemoteToken({
         token: address(0),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bsc_bridgedzil), bridgedZIL);

        // When BNB arrives at bscTokenManager, sent it to zilliqaBridgedBNB on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedBNB = ITokenManagerStructs.RemoteToken({
         token: address(zq_bridged_bnb_evm),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(0), bridgedBNB);
  }
}

