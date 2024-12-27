
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash bf1fff14761d7045227068db5e58f888de4f92b122d9c2d8e685cdb7daa861de with makeTokenRouting v1.8.1
// Generating code for network polygon


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['zil.1.6.52c256']
// Native: ['matic.1.17.3254b4']
// correspondent network: ['zilliqa']
LockProxyTokenManagerUpgradeable polLockProxyTokenManager = LockProxyTokenManagerUpgradeable(polLockProxyTokenManager);
LockAndReleaseTokenManagerUpgradeable polLockAndReleaseOrNativeTokenManager = LockAndReleaseTokenManagerUpgradeable(polLockAndReleaseOrNativeTokenManagerUpgradeable);
// bridged to polygon: token zil.1.6.52c256 has zq_denom zil.1.18.1a4a06, name ZIL and is on zilliqa as 0x0000000000000000000000000000000000000000, zil.1.18.1a4a06

            ITokenManagerStructs.RemoteToken memory ZILBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });

            polLockProxyTokenManager.registerToken(address(0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17), ZILBridgedTokenRouting);
            
// native on polygon: token matic.1.17.3254b4 has zq_denom zmatic.1.18.45185c, name zMATIC and is on zilliqa as 0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b, zmatic.1.18.45185c

            ITokenManagerStructs.RemoteToken memory zMATICNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b),
              tokenManager: address(zilLockProxyTokenManager),
              chainId: zilChainId });
            polLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), zMATICNativeTokenRouting);
            

    vm.stopBroadcast();
 }
}

