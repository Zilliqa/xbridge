
// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash 62b9fe1d5dddd38e9c8b33d45df514808ba7f4f501057ef059f70d3192e71a4d with makeTokenRouting v1.9.0
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

// bridged to zilliqa: token zopul.1.18.4bcdc9 has zq_denom zopul.1.18.4bcdc9, name zOPUL and is on ethereum as 0x80D55c03180349Fff4a229102F62328220A96444, opul.1.2.d9af8f

            ITokenManagerStructs.RemoteToken memory zOPULBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x80D55c03180349Fff4a229102F62328220A96444),
            tokenManager: address(ethLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: ethChainId });

            zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x8DEAdC20f7218994c86b59eE1D5c7979fFcAa893), zOPULBridgedTokenRouting);

    vm.stopBroadcast();
 }
}

