// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";

/*** @title Route tokens from the BSC side.
 */
contract Deployment is Script {
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        uint bscChainId = 6;
        uint zilliqaChainId = 18;
        
        address bscERC20 = 0x43b1e04b72Aca6aA54c49f540Ef8ea3970d2A541;
        address zilliqaBridgedERC20 = 0x839901f1e39De75301667C6bBbF7fB556Ea2510E;

        address bscBridgedZRC2FromZilliqa = 0x190b6601E1D9bAF0c9413b08C27C5cBEa275D55F;
        address zilliqaZRC2 = 0x155F0f76b660290F2F00Bb5674b80eDC208bF2e6;

        address bscBridgedZIL = 0x09AbdfE544Ca946808261ce761e1e86b91581C6c;
        address zilliqaBridgedBNB = 0x06852e68A3c24917cfA4C2dbDaE4B308C69aDA5e;

        address zilliqaTokenManager = 0xBe90AB2cd65E207F097bEF733F8D239A59698b8A;
        address bscTokenManager = 0x103617938D41f7bea62F0B5b4E8e50585083048F;

        // OK. Now set up the routing ..

        // When bscERC20 arrives at bscTokenManager, send it to zilliqaBridgedERC20 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory sourceBscERC20GasStruct = ITokenManagerStructs.RemoteToken({
         token: address(zilliqaBridgedERC20),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bscERC20), sourceBscERC20GasStruct);

        // When bscBridgedZRC2FromZilliqa arrives at bscTokenManager, send it to zilliqaZRC2 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZRC2 = ITokenManagerStructs.RemoteToken({
         token: address(zilliqaZRC2),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bscBridgedZRC2FromZilliqa), bridgedZRC2);

        // When bscBridgedZIL arrives at bscTokenManager, send it to 0 on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedZIL = ITokenManagerStructs.RemoteToken({
         token: address(0),
         tokenManager: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        bscTokenManager.registerToken(address(bscBridgedZIL), bridgedZIL);

        // When BNB arrives at bscTokenManager, sent it to zilliqaBridgedBNB on zilliqaTokenManager
        ITokenManagerStructs.RemoteToken memory bridgedBNB = ITokenManagerStructs.RemoteToken({
         token: address(zilliqaBridgedBNB),
         token: address(zilliqaTokenManager),
         chainId: zilliqaChainId});
        zilliqaTokenManager.registerToken(address(0), bridgedBNB);
  }
}

