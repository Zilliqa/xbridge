// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash d507772d58dde3626ba755e70e13d18fb3446f1b8846af51a108e8bdc698a46d with makeTokenRouting v1.7.2
// Generating code for network polygon


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";

contract Routing is Script, MainnetConfig {
  function run() external {

// Bridged: ['zil.1.6.52c256']
// Native: ['matic.1.17.3254b4']
// correspondent network: ['zilliqa']
LockProxyTokenManagerUpgradeable polLockProxyTokenManager = LockProxyTokenManagerUpgradeable(polLockProxyTokenManager)
LockAndReleaseTokenManagerUpgradeable polLockAndReleaseOrNativeTokenManager = LockAndReleaseTokenManagerUpgradeable(polLockAndReleaseOrNativeTokenManagerUpgradeable)
// bridged to polygon: token zil.1.6.52c256 has zq_denom zil.1.18.1a4a06, name ZIL and is on zilliqa as 0x0000000000000000000000000000000000000000, zil.1.18.1a4a06

            ITokenManagerStructs.RemoteToken memory ZILBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zqChainId });

            polLockProxyTokenManager.registerToken(address(0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17), ZILBridgedTokenRouting);
            
// native on polygon: token matic.1.17.3254b4 has zq_denom zmatic.1.18.45185c, name zMATIC and is on zilliqa as 0xa1A172999AD3C5d457536c48736e30F53Bc260C9, zmatic.1.18.45185c

            ITokenManagerStructs.RemoteToken memory zMATICNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xa1A172999AD3C5d457536c48736e30F53Bc260C9),
              tokenManager: address(zilLockProxyTokenManager),
              chainId: zqChainId });
            polLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), zMATICNativeTokenRouting);
            

 }
}
