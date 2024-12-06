// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "test/zilbridge/infrastructure/lockProxy.sol";
import { EthCrossChainManagerProxy } from "test/zilbridge/infrastructure/ccmProxy.sol";
import { EthCrossChainManager } from "test/zilbridge/infrastructure//ccmCrossChainManager.sol";
import { EthCrossChainData } from "test/zilbridge/infrastructure/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/periphery/ZilBridge/ccmExtendCrossChainManager.sol";
import { ZilBridgeFixture } from "./DeployZilBridge.t.sol";

contract ZilBridgeTransferTest is ZilBridgeFixture {
  function test_installNativeTokenBridge() external {
    //setUpZilBridgeForTesting();
    //installTokenManager();
  }
}
