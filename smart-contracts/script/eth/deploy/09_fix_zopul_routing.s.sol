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

// native on ethereum: token opul.1.2.d9af8f has zq_denom zopul.1.18.4bcdc9, name zOPUL and is on zilliqa as 0x8DEAdC20f7218994c86b59eE1D5c7979fFcAa893, zopul.1.18.4bcdc9

            ITokenManagerStructs.RemoteToken memory zOPULNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0x8DEAdC20f7218994c86b59eE1D5c7979fFcAa893),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });

                ethLockAndReleaseOrNativeTokenManager.registerToken(address(0x80D55c03180349Fff4a229102F62328220A96444), zOPULNativeTokenRouting);

    vm.stopBroadcast();
 }
}

