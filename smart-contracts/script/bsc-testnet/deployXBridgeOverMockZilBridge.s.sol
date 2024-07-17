// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import { EthCrossChainManagerProxy } from "contracts/zilbridge/1/ccmProxy.sol";
import { EthCrossChainManager } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { EthCrossChainData } from "contracts/zilbridge/1/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/zilbridge/2/ccmExtendCrossChainManager.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerDeployer } from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import { TestnetConfig } from "script/testnet_config.s.sol";

/*** @notice ZilBridgeFixture::installExtendCrossManager() */
contract deployXBridgeOverMockZilBridge is Script, TestnetConfig {
  // Plug in the data from deployMockZilBridge here.
  EthCrossChainData public constant eccd = EthCrossChainData(bsc_EthCrossChainData);
  EthCrossChainManager public constant ccm = EthCrossChainManager(bsc_ccm);
  EthCrossChainManagerProxy public constant ccmProxy = EthCrossChainManagerProxy(bsc_ccmProxy);
  LockProxy public constant lockProxy = LockProxy(payable(bsc_lockProxy));
  EthExtendCrossChainManager extendCCM;

  function run() external {
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    vm.startBroadcast(deployerPrivateKey);
    // address owner = vm.addr(deployerPrivateKey);
    extendCCM = new EthExtendCrossChainManager(address(eccd), 2, a, b);
    ccmProxy.pauseEthCrossChainManager();
    extendCCM.transferOwnership(address(ccmProxy));
    ccmProxy.upgradeEthCrossChainManager(address(extendCCM));
    ccmProxy.unpauseEthCrossChainManager();
    console.log("extendCCM: %s", address(extendCCM));
  }
}
