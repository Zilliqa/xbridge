// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash ec60b3dffbf1ac42d350b8985db67c7eef7704e46d8c16ae621cfde1504ddca6 with makeTokenRouting v1.9.0
// Generating code for network ethereum


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['ezil.1.2.f1b7e4', 'elunr.1.2.e2121e', 'dxcad.1.2.67dde7', 'eport.1.2.7d4912', 'efees.1.2.586fb5']
// Native: ['xcad.1.2.9bb504', 'opul.1.2.d9af8f', 'eth.1.2.942d87', 'brkl.1.2.797e04', 'wbtc.1.2.786598', 'usdt.1.2.556c4e', 'traxx.1.2.9442ae']
// correspondent network: ['zilliqa']
LockProxyTokenManagerUpgradeableV4 ethLockProxyTokenManager = LockProxyTokenManagerUpgradeableV4(payable(ethLockProxyTokenManager));
LockAndReleaseOrNativeTokenManagerUpgradeableV4 ethLockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(ethLockAndReleaseOrNativeTokenManagerUpgradeable));
// bridged to ethereum: token ezil.1.2.f1b7e4 has zq_denom zil.1.18.1a4a06, name ZIL and is on zilliqa as 0x0000000000000000000000000000000000000000, zil.1.18.1a4a06

            ITokenManagerStructs.RemoteToken memory ZILBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });

                // *** Bridging wrapped ZIL to native ZIL with decimals=18, scaling +6
                ethLockProxyTokenManager.registerTokenWithScale(address(0x6EeB539D662bB971a4a01211c67CB7f65B09b802), ZILBridgedTokenRouting, 6);

// bridged to ethereum: token elunr.1.2.e2121e has zq_denom lunr.1.18.fa4af7, name Lunr and is on zilliqa as 0xE9D47623bb2B3C497668B34fcf61E101a7ea4058, lunr.1.18.fa4af7

            ITokenManagerStructs.RemoteToken memory LunrBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0xE9D47623bb2B3C497668B34fcf61E101a7ea4058),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                ethLockProxyTokenManager.registerToken(address(0xA87135285Ae208e22068AcDBFf64B11Ec73EAa5A), LunrBridgedTokenRouting);
                
// bridged to ethereum: token dxcad.1.2.67dde7 has zq_denom dxcad.1.18.9dfb98, name dXCAD and is on zilliqa as 0xa0A5795e7eccc43Ba92d2A0b7804696F8B9e1a05, dxcad.1.18.9dfb98

            ITokenManagerStructs.RemoteToken memory dXCADBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0xa0A5795e7eccc43Ba92d2A0b7804696F8B9e1a05),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                ethLockProxyTokenManager.registerToken(address(0xBd636FFfbF349A4479db315c585E823164cF58F0), dXCADBridgedTokenRouting);
                
// bridged to ethereum: token eport.1.2.7d4912 has zq_denom port.1.18.b2261e, name PORT and is on zilliqa as 0x1202078D298Ff0358A95b6fbf48Ec166dB414660, port.1.18.b2261e

            ITokenManagerStructs.RemoteToken memory PORTBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x1202078D298Ff0358A95b6fbf48Ec166dB414660),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                ethLockProxyTokenManager.registerToken(address(0x0c7c5b92893A522952EB4c939aA24B65FF910C48), PORTBridgedTokenRouting);
                
// bridged to ethereum: token efees.1.2.586fb5 has zq_denom fees.1.18.c061fe, name UNIFEES and is on zilliqa as 0xc99ECB82a27B45592eA02ACe9e3C42050f3c00C0, fees.1.18.c061fe

            ITokenManagerStructs.RemoteToken memory UNIFEESBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0xc99ECB82a27B45592eA02ACe9e3C42050f3c00C0),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                ethLockProxyTokenManager.registerToken(address(0xf7030C3f43b85874ae12B57F44cd682196568b47), UNIFEESBridgedTokenRouting);
                
// native on ethereum: token xcad.1.2.9bb504 has zq_denom zxcad.1.18.35137d, name XCAD and is on zilliqa as 0xCcF3Ea256d42Aeef0EE0e39Bfc94bAa9Fa14b0Ba, zxcad.1.18.35137d

            ITokenManagerStructs.RemoteToken memory XCADNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xCcF3Ea256d42Aeef0EE0e39Bfc94bAa9Fa14b0Ba),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x7659CE147D0e714454073a5dd7003544234b6Aa0), XCADNativeTokenRouting);
                
// native on ethereum: token opul.1.2.d9af8f has zq_denom zopul.1.18.4bcdc9, name zOPUL and is on zilliqa as 0x17D5af5658A24bd964984b36d28e879a8626adC3, zopul.1.18.4bcdc9

            ITokenManagerStructs.RemoteToken memory zOPULNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x17D5af5658A24bd964984b36d28e879a8626adC3),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x80D55c03180349Fff4a229102F62328220A96444), zOPULNativeTokenRouting);
                
// native on ethereum: token eth.1.2.942d87 has zq_denom zeth.1.18.54437c, name zETH and is on zilliqa as 0x17D5af5658A24bd964984b36d28e879a8626adC3, zeth.1.18.54437c

            ITokenManagerStructs.RemoteToken memory zETHNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x17D5af5658A24bd964984b36d28e879a8626adC3),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), zETHNativeTokenRouting);
                
// native on ethereum: token brkl.1.2.797e04 has zq_denom zbrkl.1.18.b8c24f, name zBRKL and is on zilliqa as 0xD819257C964A78A493DF93D5643E9490b54C5af2, zbrkl.1.18.b8c24f

            ITokenManagerStructs.RemoteToken memory zBRKLNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xD819257C964A78A493DF93D5643E9490b54C5af2),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x4674a4F24C5f63D53F22490Fb3A08eAAAD739ff8), zBRKLNativeTokenRouting);
                
// native on ethereum: token wbtc.1.2.786598 has zq_denom zwbtc.1.18.a9cb60, name zWBTC and is on zilliqa as 0x2938fF251Aecc1dfa768D7d0276eB6d073690317, zwbtc.1.18.a9cb60

            ITokenManagerStructs.RemoteToken memory zWBTCNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x2938fF251Aecc1dfa768D7d0276eB6d073690317),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599), zWBTCNativeTokenRouting);
                
// native on ethereum: token usdt.1.2.556c4e has zq_denom zusdt.1.18.1728e9, name zUSDT and is on zilliqa as 0x2274005778063684fbB1BfA96a2b725dC37D75f9, zusdt.1.18.1728e9

            ITokenManagerStructs.RemoteToken memory zUSDTNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x2274005778063684fbB1BfA96a2b725dC37D75f9),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0xdAC17F958D2ee523a2206206994597C13D831ec7), zUSDTNativeTokenRouting);
                
// native on ethereum: token traxx.1.2.9442ae has zq_denom ztraxx.1.18.9c8e35, name zTRAXX and is on zilliqa as 0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b, ztraxx.1.18.9c8e35

            ITokenManagerStructs.RemoteToken memory zTRAXXNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0xD43Be54C1aedf7Ee4099104f2DaE4eA88B18A249), zTRAXXNativeTokenRouting);
                

    vm.stopBroadcast();
 }
}

