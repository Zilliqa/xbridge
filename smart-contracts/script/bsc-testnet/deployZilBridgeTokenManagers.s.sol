// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import { TestingLockProxy } from "test/zilbridge/TestingLockProxy.sol";
import { EthCrossChainManagerProxy } from "contracts/zilbridge/1/ccmProxy.sol";
import { EthCrossChainManager } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { EthCrossChainData } from "contracts/zilbridge/1/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/zilbridge/2/ccmExtendCrossChainManager.sol";
import { ChainGateway } from "contracts/core/ChainGateway.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerDeployer } from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerDeployer} from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {MintAndBurnTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/MintAndBurnTokenManagerDeployer.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import { TestnetConfig } from "script/testnet_config.s.sol";

/*** @notice Deploy token managers over the extension manager
 */
contract deployZilBridgeTokenManagers is Script, LockProxyTokenManagerDeployer, TestnetConfig {
  EthExtendCrossChainManager constant extendCCM = EthExtendCrossChainManager(bsc_extendCCM);
  ChainGateway constant chainGateway = ChainGateway(bsc_chainGateway);
  LockProxy constant lockProxy = LockProxy(payable(bsc_lockProxy));
  // Different from 0.00025 so that we can tell the difference!
  uint fees = 0.00007 ether;

  // This has to be 18, because that is what the original (ZilBridge) contracts were
  // deployed with. The mainnet value is 5.
  uint64 constant COUNTERPART_CHAIN_ID = 18;

  function run() external {
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
    uint256 bridgePrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    // address validator = vm.addr(validatorPrivateKey);
    // address bridgeOwner = vm.addr(bridgePrivateKey);
    // token managers are apparently not pausable, so ..
    vm.startBroadcast(validatorPrivateKey);
    LockProxyTokenManagerUpgradeableV3 tokenManager = deployLatestLockProxyTokenManager(address(chainGateway), address(lockProxy), fees);
    console.log("bsc_zilBridgeTokenManager: %s", address(tokenManager));
    vm.stopBroadcast();
    vm.startBroadcast(bridgePrivateKey);
    extendCCM.forciblyAddExtension(address(lockProxy), address(tokenManager), COUNTERPART_CHAIN_ID);
    vm.stopBroadcast();
    vm.startBroadcast(validatorPrivateKey);
    chainGateway.register(address(tokenManager));
    vm.stopBroadcast();
  }
}
