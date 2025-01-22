// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash ec60b3dffbf1ac42d350b8985db67c7eef7704e46d8c16ae621cfde1504ddca6 with makeTokenRouting v1.9.0
// Generating code for network arbitrum


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['zil.1.19.0f16f8']
// Native: ['eth.1.19.c3b805']
// correspondent network: ['zilliqa']
LockProxyTokenManagerUpgradeableV4 arbLockProxyTokenManager = LockProxyTokenManagerUpgradeableV4(payable(arbLockProxyTokenManager));
LockAndReleaseOrNativeTokenManagerUpgradeableV4 arbLockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(arbLockAndReleaseOrNativeTokenManagerUpgradeable));
// bridged to arbitrum: token zil.1.19.0f16f8 has zq_denom zil.1.18.1a4a06, name ZIL and is on zilliqa as 0x0000000000000000000000000000000000000000, zil.1.18.1a4a06

            ITokenManagerStructs.RemoteToken memory ZILBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                // *** Bridging wrapped ZIL to native ZIL with decimals=18, scaling +6
                arbLockProxyTokenManager.registerTokenWithScale(address(0x1816A0f20bc996F643B1aF078e8D84a0aaBD772A), ZILBridgedTokenRouting, 6);
                
// native on arbitrum: token eth.1.19.c3b805 has zq_denom zeth.1.18.54437c, name zETH and is on zilliqa as 0x17D5af5658A24bd964984b36d28e879a8626adC3, zeth.1.18.54437c

            ITokenManagerStructs.RemoteToken memory zETHNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x17D5af5658A24bd964984b36d28e879a8626adC3),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                arbLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), zETHNativeTokenRouting);
                

    vm.stopBroadcast();
 }
}

