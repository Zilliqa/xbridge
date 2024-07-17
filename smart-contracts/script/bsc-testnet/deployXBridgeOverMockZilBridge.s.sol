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

/*** @notice ZilBridgeFixture::installExtendCrossManager() */
contract deployXBridgeOverMockZilBridge is Script {
  // Plug in the data from deployMockZilBridge here.
  EthCrossChainData public constant eccd = EthCrossChainData(0xd677494525D25238Fedd554796eEa5733a9B86a2);
  EthCrossChainManager public constant ccm = EthCrossChainManager(0xff4AC43f368676765de511F82B816EED9b9D780c);
  EthCrossChainManagerProxy public constant ccmProxy = EthCrossChainManagerProxy(0xd7a76e4454c4f4F80E6409DF361B7926a1789d93);
  LockProxy public constant lockProxy = LockProxy(payable(0x218D8aFE24bb2a0d1DE483Ff67aCADB45Ac8Bd2d));
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
