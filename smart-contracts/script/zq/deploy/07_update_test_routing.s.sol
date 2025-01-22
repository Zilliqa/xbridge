
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

LockAndReleaseOrNativeTokenManagerUpgradeableV4 zilLockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(zilLockAndReleaseOrNativeTokenManagerUpgradeable));

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
            

                // *** Bridging decimals=18 native ZIL to wrapped ZIL with decimals=12; scaling by -6 
            zilLockAndReleaseOrNativeTokenManager.registerTokenWithScale(address(0x0000000000000000000000000000000000000000), ZILNativeTokenRouting, -6);
                

    vm.stopBroadcast();
 }
}

