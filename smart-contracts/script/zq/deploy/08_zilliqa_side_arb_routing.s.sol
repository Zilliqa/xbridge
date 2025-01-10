
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

// bridged to zilliqa: token zeth.1.18.54437c has zq_denom zeth.1.18.54437c, name zETH and is on arbitrum as 0x0000000000000000000000000000000000000000, eth.1.19.c3b805

            ITokenManagerStructs.RemoteToken memory zETHBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(arbLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: arbChainId });
            

                zilLockAndReleaseOrNativeTokenManager.registerToken(address(0x17D5af5658A24bd964984b36d28e879a8626adC3), zETHBridgedTokenRouting);
                
// native on zilliqa: token zil.1.18.1a4a06 has zq_denom zil.1.18.1a4a06, name ZIL and is on arbitrum as 0x1816A0f20bc996F643B1aF078e8D84a0aaBD772A, zil.1.19.0f16f8

            ITokenManagerStructs.RemoteToken memory ZILNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x1816A0f20bc996F643B1aF078e8D84a0aaBD772A),
              tokenManager: address(arbLockProxyTokenManager),
              chainId: arbChainId });
            

                // *** Bridging decimals=18 native ZIL to wrapped ZIL with decimals=12; scaling by -6 
                zilLockAndReleaseOrNativeTokenManager.registerTokenWithScale(address(0x0000000000000000000000000000000000000000), ZILNativeTokenRouting, -6);
                


    vm.stopBroadcast();
 }
}

