// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "test/zilbridge/infrastructure/lockProxy.sol";
import { EthCrossChainManagerProxy } from "test/zilbridge/infrastructure/ccmProxy.sol";
import { EthCrossChainManager } from "test/zilbridge/infrastructure/ccmCrossChainManager.sol";
import { EthCrossChainData } from "test/zilbridge/infrastructure/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/periphery/ZilBridge/ccmExtendCrossChainManager.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerDeployer } from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

/*** @notice ZilBridgeFixture::installExtendCrossManager() */
contract deployXBridgeOverMockZilBridge is Script, TestnetConfig {
  // Plug in the data from deployMockZilBridge here.
  EthCrossChainData public constant eccd = EthCrossChainData(bscEthCrossChainDataAddress);
  EthCrossChainManager public constant ccm = EthCrossChainManager(bscCCMAddress);
  EthCrossChainManagerProxy public constant ccmProxy = EthCrossChainManagerProxy(bscCCMProxyAddress);
  LockProxy public constant lockProxy = LockProxy(payable(bscLockProxyAddress));
  EthExtendCrossChainManager extendCCM;

  function run() external {
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    vm.startBroadcast(deployerPrivateKey);
    extendCCM = new EthExtendCrossChainManager(address(eccd), 2, a, b);
    ccmProxy.pauseEthCrossChainManager();
    extendCCM.transferOwnership(address(ccmProxy));
    ccmProxy.upgradeEthCrossChainManager(address(extendCCM));
    ccmProxy.unpauseEthCrossChainManager();
    console.log(
        "    address public constant bscExtendCCMAddress = %s", address(extendCCM));
  }
}
