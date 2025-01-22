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
    address lockProxyProxy = 0x57b679d10fC16Cb62E6441922851728aF915aFe1;
    tokenManager.setLockProxyData(address(lockProxy), address(lockProxyProxy));
    vm.stopBroadcast();
  }
}
