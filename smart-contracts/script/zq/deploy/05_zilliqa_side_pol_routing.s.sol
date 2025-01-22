
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash bf1fff14761d7045227068db5e58f888de4f92b122d9c2d8e685cdb7daa861de with makeTokenRouting v1.8.1
// Generating code for network zilliqa


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['zxcad.1.18.35137d', 'zopul.1.18.4bcdc9', 'zeth.1.18.54437c', 'zbrkl.1.18.b8c24f', 'zwbtc.1.18.a9cb60', 'zusdt.1.18.1728e9', 'ztraxx.1.18.9c8e35', 'zmatic.1.18.45185c', 'zbnb.1.18.c406be']
// Native: ['zil.1.18.1a4a06', 'xsgd.1.18.be52cd', 'lunr.1.18.fa4af7', 'dxcad.1.18.9dfb98', 'port.1.18.b2261e', 'fees.1.18.c061fe']
// correspondent network: ['bsc', 'polygon', 'arbitrum', 'ethereum']
LockProxyTokenManagerUpgradeable zilLockProxyTokenManager = LockProxyTokenManagerUpgradeable(zilLockProxyTokenManager);
LockAndReleaseTokenManagerUpgradeable zilLockAndReleaseOrNativeTokenManager = LockAndReleaseTokenManagerUpgradeable(zilLockAndReleaseOrNativeTokenManagerUpgradeable);

// bridged to zilliqa: token zmatic.1.18.45185c has zq_denom zmatic.1.18.45185c, name zMATIC and is on polygon as 0x0000000000000000000000000000000000000000, matic.1.17.3254b4

            ITokenManagerStructs.RemoteToken memory zMATICBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(polLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: polChainId });

            zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b), zMATICBridgedTokenRouting);

// native on zilliqa: token zil.1.18.1a4a06 has zq_denom zil.1.18.1a4a06, name ZIL and is on polygon as 0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17, zil.1.6.52c256

            ITokenManagerStructs.RemoteToken memory ZILNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xCc88D28f7d4B0D5AFACCC77F6102d88EE630fA17),
              tokenManager: address(polLockProxyTokenManager),
              chainId: polChainId });
            zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), ZILNativeTokenRouting);

    vm.stopBroadcast();
 }
}

