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


/*** @title Route tokens from the BSC side.
 */
contract Deployment is Script {
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        // The BSC testnet chain id (this is an XBridge ID, not a zilBridge one).
        uint bscChainId = 97;
        // Zilliqa chain id
        uint zilliqaChainId = 33101;

        address bscERC20 = 0x43b1e04b72Aca6aA54c49f540Ef8ea3970d2A541;
        address zilliqaBridgedERC20 = address(0x00839901f1e39De75301667C6bBbF7fB556Ea2510E);

        address bscBridgedZRC2FromZilliqa = 0x190b6601E1D9bAF0c9413b08C27C5cBEa275D55F;
        address zilliqaZRC2 = address(0x00155F0f76b660290F2F00Bb5674b80eDC208bF2e6);

        address bscBridgedZIL = 0x09AbdfE544Ca946808261ce761e1e86b91581C6c;
        address zilliqaBridgedBNB = address(0x0006852e68A3c24917cfA4C2dbDaE4B308C69aDA5e);

        LockAndReleaseTokenManagerUpgradeable zilliqaTokenManager = LockAndReleaseTokenManagerUpgradeable(address(0x00Be90AB2cd65E207F097bEF733F8D239A59698b8A));
        LockProxyTokenManagerUpgradeable bscTokenManager = LockProxyTokenManagerUpgradeable(0x103617938D41f7bea62F0B5b4E8e50585083048F);

        // OK. Now set up the routing ..

        // When zilliqaBridgedERC20 arrives at zilliqaTokenManager, send it to bscERC20 on bscTokenManager 
        ITokenManagerStructs.RemoteToken memory sourceBscERC20GasStruct = ITokenManagerStructs.RemoteToken({
         token: address(bscERC20),
         tokenManager: address(bscTokenManager),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zilliqaBridgedERC20), sourceBscERC20GasStruct);

        // When zilliqaZRC2 arrives at zilliqaTokenManager, send it to bscBridgedZRC2FromZilliqa on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZRC2 = ITokenManagerStructs.RemoteToken({
         token: address(bscBridgedZRC2FromZilliqa),
         tokenManager: address(bscTokenManager),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zilliqaZRC2), bridgedZRC2);

        // When ZIL arrives at zilliqaTokenManager, send it to bscBridgedZIL on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZIL = ITokenManagerStructs.RemoteToken({
         token: address(bscBridgedZIL),
         tokenManager: address(bscTokenManager),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(0), bridgedZIL);

        // When zilliqaBridgedBNB arrives at zilliqaTokenManager, send it to 0 on bscTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedBNB = ITokenManagerStructs.RemoteToken({
         token: address(0),
         tokenManager: address(bscTokenManager),
         chainId: bscChainId});
        zilliqaTokenManager.registerToken(address(zilliqaBridgedBNB), bridgedBNB);
  }
}

