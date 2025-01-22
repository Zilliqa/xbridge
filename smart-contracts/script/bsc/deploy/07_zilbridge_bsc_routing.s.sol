// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;


// Reading token file tokens-2024-12-05.yaml hash 4e440b868c5c13ef0632be6415adcbc11691d947915067567387cc4402ea3cee with makeTokenRouting v1.9.0
// Generating code for network bsc


import {Script} from "forge-std/Script.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MainnetConfig} from "script/mainnetConfig.s.sol";


contract Routing is Script, MainnetConfig {
  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    vm.startBroadcast(deployerPrivateKey);


// Bridged: ['zil.1.6.52c256']
// Native: ['bnb.1.6.773edb']
// correspondent network: ['zilliqa']
LockProxyTokenManagerUpgradeableV4 bscLockProxyTokenManager = LockProxyTokenManagerUpgradeableV4(payable(bscLockProxyTokenManager));
LockAndReleaseOrNativeTokenManagerUpgradeableV4 bscLockAndReleaseOrNativeTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(bscLockAndReleaseOrNativeTokenManagerUpgradeable));
// bridged to bsc: token zil.1.6.52c256 has zq_denom zil.1.18.1a4a06, name ZIL and is on zilliqa as 0x0000000000000000000000000000000000000000, zil.1.18.1a4a06

            ITokenManagerStructs.RemoteToken memory ZILBridgedTokenRouting = ITokenManagerStructs.RemoteToken({
            token: address(0x0000000000000000000000000000000000000000),
            tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
            chainId: zilChainId });
            

                // *** Bridging wrapped ZIL to native ZIL with decimals=18, scaling +6
                bscLockProxyTokenManager.registerTokenWithScale(address(0xb1E6F8820826491FCc5519f84fF4E2bdBb6e3Cad), ZILBridgedTokenRouting, 6);
                
// native on bsc: token bnb.1.6.773edb has zq_denom zbnb.1.18.c406be, name zBNB and is on zilliqa as 0xea87bC6CcaE73bae35693639e22eF30667760F61, zbnb.1.18.c406be

            ITokenManagerStructs.RemoteToken memory zBNBNativeTokenRouting = ITokenManagerStructs.RemoteToken({
              token: address(0xea87bC6CcaE73bae35693639e22eF30667760F61),
              tokenManager: address(zilLockAndReleaseOrNativeTokenManagerUpgradeable),
              chainId: zilChainId });
            

                bscLockAndReleaseOrNativeTokenManager.registerToken(address(0x0000000000000000000000000000000000000000), zBNBNativeTokenRouting);
                

    vm.stopBroadcast();
 }
}

