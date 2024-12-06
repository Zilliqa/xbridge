// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { EthExtendCrossChainManager } from "contracts/periphery/ZilBridge/ccmExtendCrossChainManager.sol";
import { Utils, ZeroCopySink, ZeroCopySource } from "test/zilbridge/infrastructure/ccmCrossChainManager.sol";
import { EthCrossChainData } from "test/zilbridge/infrastructure/ethCrossChainData.sol";
import { ZilBridgeFixture } from "./DeployZilBridge.t.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";

contract ccmExtendCrossChainManager is ZilBridgeFixture {

  function test_extensionManagerValue() external {
    setUpZilBridgeForTesting();
    require(extendCCM._extensionManager() == owner);
    require(extendCCM.extensionManager() == owner);
  }

  function testFail_invalidRenounce() external {
    setUpZilBridgeForTesting();
    vm.startPrank(other);
    extendCCM.renounceExtensionManagement();
    vm.stopPrank();
  }

  function testFail_invalidTransfer() external {
    setUpZilBridgeForTesting();
    vm.startPrank(other);
    extendCCM.transferExtensionManagement(third);
    vm.stopPrank();
  }

  function test_transferExtensionManager() external {
    setUpZilBridgeForTesting();
    vm.startPrank(owner);
    extendCCM.transferExtensionManagement(other);
    vm.stopPrank();
    vm.startPrank(other);
    extendCCM.transferExtensionManagement(third);
    vm.stopPrank();
  }

  // TODO: remainder of the authorisation tests for transferExtensionManager.

  function test_addExtension() external {
    setUpZilBridgeForTesting();
    uint fees = 0.1 ether;
    // Create a lock proxy token manager - fake out the source chain gateway
    address[] memory addresses = new address[](0);
    LockProxyProxy lpp = new LockProxyProxy(addresses, address(this), address(lockProxy));
    installLockProxyProxy(address(lpp));
    require(lockProxy.extensions(address(lpp))==true);
  }

  function test_Pickle() view external {
    console.log("owner = %s", owner);
    bytes memory payload = ZeroCopySink.WriteVarBytes(Utils.addressToBytes(owner));
    console.logBytes(payload);
    uint256 off = 0;
    bytes memory result;
    {
      bytes1 v;
      uint256 offset = 0;
      (v,offset) = ZeroCopySource.NextByte(payload, offset);
      console.log("F");
      console.logBytes1(v);
    }
    {
      uint len;
      uint256 offset = 0;
      (len,offset) = ZeroCopySource.NextVarUint(payload, offset);
      console.log("len = %d offset = %d payload = %d", len, offset, payload.length);
    }
    (result, off) = ZeroCopySource.NextVarBytes(payload, off);
    console.logBytes(result);
  }
}

