// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";
import { LockProxy } from "test/zilbridge/infrastructure/lockProxy.sol";
import "forge-std/console.sol";
import { EthExtendCrossChainManager } from "contracts/periphery/ZilBridge/ccmExtendCrossChainManager.sol";

contract Upgrade is Script,TestnetConfig {
  uint64 constant COUNTERPART_CHAIN_ID = zbZilliqaChainId;
  EthExtendCrossChainManager constant extendCCM = EthExtendCrossChainManager(bscExtendCCMAddress);

  function run() external {
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
    uint256 bridgePrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    address owner = vm.addr(deployerPrivateKey);
    console.log("Signer is %s", owner);
    vm.startBroadcast(deployerPrivateKey);
    LockProxyTokenManagerUpgradeableV4 tokenManager = LockProxyTokenManagerUpgradeableV4(bscLockProxyTokenManagerAddress);
    LockProxy lockProxy = LockProxy(payable(bscLockProxyAddress));
    address[] memory allowedTokens = new address[](3);
    allowedTokens[0] = bscERC20Address;
    allowedTokens[1] = bscBridgedZRC2Address;
    allowedTokens[2] = bscBridgedZILAddress;
    LockProxyProxy lockProxyProxy = new LockProxyProxy(allowedTokens, vm.addr(deployerPrivateKey), address(lockProxy));
    lockProxyProxy.addCaller(address(tokenManager));
    console.log("lockProxyProxy is ", address(lockProxyProxy));
    tokenManager.setLockProxyData(address(lockProxy), address(lockProxyProxy));
    vm.stopBroadcast();
    vm.startBroadcast(bridgePrivateKey);
    extendCCM.forciblyAddExtension(address(lockProxy), address(lockProxyProxy), COUNTERPART_CHAIN_ID);
    vm.stopBroadcast();
    
  }
}
