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

/*** @notice does what ZilBridgeFixture::deployOriginalContracts() does */
contract deployMockZilBridge is Script {
  uint64 constant CHAIN_ID=6;
  uint64 constant COUNTERPART_CHAIN_ID=18;

  function run() external {
    EthCrossChainManager ccm;
    EthCrossChainManagerProxy ccmProxy;
    EthCrossChainData eccd;
    LockProxy lockProxy;

    uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    address owner = vm.addr(deployerPrivateKey);
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    vm.startBroadcast(deployerPrivateKey);
    console.log("Owner: %s", owner);
    eccd = new EthCrossChainData();
    console.log("ECCD: %s", address(eccd));
    ccm = new EthCrossChainManager(address(eccd), CHAIN_ID, a, b);
    console.log("CCM: %s", address(ccm));
    ccmProxy = new EthCrossChainManagerProxy(address(ccm));
    console.log("CCMProxy: %s", address(ccmProxy));
    ccm.transferOwnership(address(ccmProxy));
    eccd.transferOwnership(address(ccm));
    lockProxy = new LockProxy(address(ccmProxy), COUNTERPART_CHAIN_ID);
    console.log("LockProxy: %s",address(lockProxy));
  }
}
