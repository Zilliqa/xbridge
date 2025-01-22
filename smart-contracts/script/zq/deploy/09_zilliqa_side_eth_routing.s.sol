// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash ec60b3dffbf1ac42d350b8985db67c7eef7704e46d8c16ae621cfde1504ddca6 with makeTokenRouting v1.9.0
// Generating code for network zilliqa


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['zxcad.1.18.35137d', 'zopul.1.18.4bcdc9', 'zeth.1.18.54437c', 'zbrkl.1.18.b8c24f', 'zwbtc.1.18.a9cb60', 'zusdt.1.18.1728e9', 'ztraxx.1.18.9c8e35', 'zmatic.1.18.45185c', 'zbnb.1.18.c406be']
// Native: ['zil.1.18.1a4a06', 'xsgd.1.18.be52cd', 'lunr.1.18.fa4af7', 'dxcad.1.18.9dfb98', 'port.1.18.b2261e', 'fees.1.18.c061fe']
// correspondent network: ['bsc', 'polygon', 'arbitrum', 'ethereum']
LockAndReleaseOrNativeTokenManagerUpgradeableV4 zilLockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(zilLockAndReleaseOrNativeTokenManagerUpgradeable));
// bridged to zilliqa: token zxcad.1.18.35137d has zq_denom zxcad.1.18.35137d, name XCAD and is on ethereum as 0x7659CE147D0e714454073a5dd7003544234b6Aa0, xcad.1.2.9bb504

            ITokenManagerStructs.RemoteToken memory XCADBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x7659CE147D0e714454073a5dd7003544234b6Aa0),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0xCcF3Ea256d42Aeef0EE0e39Bfc94bAa9Fa14b0Ba), XCADBridgedTokenRouting);
                
// bridged to zilliqa: token zopul.1.18.4bcdc9 has zq_denom zopul.1.18.4bcdc9, name zOPUL and is on ethereum as 0x80D55c03180349Fff4a229102F62328220A96444, opul.1.2.d9af8f

            ITokenManagerStructs.RemoteToken memory zOPULBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x80D55c03180349Fff4a229102F62328220A96444),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x17D5af5658A24bd964984b36d28e879a8626adC3), zOPULBridgedTokenRouting);
                

// bridged to zilliqa: token zeth.1.18.54437c has zq_denom zeth.1.18.54437c, name zETH and is on ethereum as 0x0000000000000000000000000000000000000000, eth.1.2.942d87

            ITokenManagerStructs.RemoteToken memory zETHBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x17D5af5658A24bd964984b36d28e879a8626adC3), zETHBridgedTokenRouting);
                
// bridged to zilliqa: token zbrkl.1.18.b8c24f has zq_denom zbrkl.1.18.b8c24f, name zBRKL and is on ethereum as 0x4674a4F24C5f63D53F22490Fb3A08eAAAD739ff8, brkl.1.2.797e04

            ITokenManagerStructs.RemoteToken memory zBRKLBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x4674a4F24C5f63D53F22490Fb3A08eAAAD739ff8),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0xD819257C964A78A493DF93D5643E9490b54C5af2), zBRKLBridgedTokenRouting);
                
// bridged to zilliqa: token zwbtc.1.18.a9cb60 has zq_denom zwbtc.1.18.a9cb60, name zWBTC and is on ethereum as 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599, wbtc.1.2.786598

            ITokenManagerStructs.RemoteToken memory zWBTCBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x2938fF251Aecc1dfa768D7d0276eB6d073690317), zWBTCBridgedTokenRouting);
                
// bridged to zilliqa: token zusdt.1.18.1728e9 has zq_denom zusdt.1.18.1728e9, name zUSDT and is on ethereum as 0xdAC17F958D2ee523a2206206994597C13D831ec7, usdt.1.2.556c4e

            ITokenManagerStructs.RemoteToken memory zUSDTBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0xdAC17F958D2ee523a2206206994597C13D831ec7),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x2274005778063684fbB1BfA96a2b725dC37D75f9), zUSDTBridgedTokenRouting);
                
// bridged to zilliqa: token ztraxx.1.18.9c8e35 has zq_denom ztraxx.1.18.9c8e35, name zTRAXX and is on ethereum as 0xD43Be54C1aedf7Ee4099104f2DaE4eA88B18A249, traxx.1.2.9442ae

            ITokenManagerStructs.RemoteToken memory zTRAXXBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0xD43Be54C1aedf7Ee4099104f2DaE4eA88B18A249),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b), zTRAXXBridgedTokenRouting);
                

// native on zilliqa: token zil.1.18.1a4a06 has zq_denom zil.1.18.1a4a06, name ZIL and is on ethereum as 0x6EeB539D662bB971a4a01211c67CB7f65B09b802, ezil.1.2.f1b7e4

            ITokenManagerStructs.RemoteToken memory ZILNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x6EeB539D662bB971a4a01211c67CB7f65B09b802),
              tokenManager: address(ethLockProxyTokenManager),
              chainId: ethChainId });
            

                // *** Bridging decimals=18 native ZIL to wrapped ZIL with decimals=12; scaling by -6 
                zilLockAndReleaseOrNativeTokenManager.registerTokenWithScale(address(0x0000000000000000000000000000000000000000), ZILNativeTokenRouting, -6);
                
// native on zilliqa: token lunr.1.18.fa4af7 has zq_denom lunr.1.18.fa4af7, name Lunr and is on ethereum as 0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A, elunr.1.2.e2121e

            ITokenManagerStructs.RemoteToken memory LunrNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A),
              tokenManager: address(ethLockProxyTokenManager),
              chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0xE9D47623bb2B3C497668B34fcf61E101a7ea4058), LunrNativeTokenRouting);
                
// native on zilliqa: token dxcad.1.18.9dfb98 has zq_denom dxcad.1.18.9dfb98, name dXCAD and is on ethereum as 0xBd636FFfbF349A4479db315c585E823164cF58F0, dxcad.1.2.67dde7

            ITokenManagerStructs.RemoteToken memory dXCADNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xBd636FFfbF349A4479db315c585E823164cF58F0),
              tokenManager: address(ethLockProxyTokenManager),
              chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0xa0A5795e7eccc43Ba92d2A0b7804696F8B9e1a05), dXCADNativeTokenRouting);
                
// native on zilliqa: token port.1.18.b2261e has zq_denom port.1.18.b2261e, name PORT and is on ethereum as 0x0c7c5b92893A522952EB4c939aA24B65FF910C48, eport.1.2.7d4912

            ITokenManagerStructs.RemoteToken memory PORTNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x0c7c5b92893A522952EB4c939aA24B65FF910C48),
              tokenManager: address(ethLockProxyTokenManager),
              chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x1202078D298Ff0358A95b6fbf48Ec166dB414660), PORTNativeTokenRouting);
                
// native on zilliqa: token fees.1.18.c061fe has zq_denom fees.1.18.c061fe, name UNIFEES and is on ethereum as 0xf7030C3f43b85874ae12B57F44cd682196568b47, efees.1.2.586fb5

            ITokenManagerStructs.RemoteToken memory UNIFEESNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xf7030C3f43b85874ae12B57F44cd682196568b47),
              tokenManager: address(ethLockProxyTokenManager),
              chainId: ethChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0xc99ECB82a27B45592eA02ACe9e3C42050f3c00C0), UNIFEESNativeTokenRouting);
                

    vm.stopBroadcast();
 }
}

