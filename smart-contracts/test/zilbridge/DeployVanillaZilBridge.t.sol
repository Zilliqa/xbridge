// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import { EthCrossChainManagerProxy } from "contracts/zilbridge/1/ccmproxy.sol";
import { EthCrossChainManager } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { EthCrossChainData } from "contracts/zilbridge/1/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/zilbridge/2/ccmExtendCrossChainManager.sol";


abstract contract ZilBridgeFixture is Tester {
  address owner = vm.createWallet("owner").addr;
  address tokenDeployer = vm.createWallet("tokenDeployer").addr;


  TestToken testToken;
  EthCrossChainManager ccm;
  EthCrossChainManagerProxy ccmProxy;
  EthCrossChainData eccd;
  LockProxy lockProxy;
  EthExtendCrossChainManager extendCCM;

  function setUp() internal {
    vm.prank(tokenDeployer);
    testToken = new TestToken(10_000);
  }

  function deployOriginalContracts() internal {
    vm.startPrank(owner);
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    console.log("deploy_as = %s", owner);
    eccd = new EthCrossChainData();
    ccm = new EthCrossChainManager(address(eccd), 2, a,b);
    ccmProxy = new EthCrossChainManagerProxy(address(ccm));
    // Now give the ccm to the ccmProxy
    ccm.transferOwnership(address(ccmProxy));
    // and give the data to the ccm.
    eccd.transferOwnership(address(ccm));
    lockProxy = new LockProxy(address(ccmProxy), 18);
    vm.stopPrank();
  }

  function installExtendCrossChainManager(address act_as) internal {
    vm.startPrank(act_as);
    console.log("act_as = %s", act_as);
    extendCCM = new EthExtendCrossChainManager(address(ccm));
    console.log("ccmProxy owner  = %s", ccmProxy.owner());
    console.log("ccmProxy ccm = %s", ccmProxy.getEthCrossChainManager());
    console.log("eccm owner = %s", ccm.owner());
    console.log("eccd owner = %s", eccd.owner());
    console.log("ccm = %s", address(ccm));
    ccmProxy.pauseEthCrossChainManager();
    //require(ccmProxy.upgradeEthCrossChainManager(address(extendCCM)));
    //extendCCM.handCrossChainDataBackToImplementation();
    //ccmProxy.unpauseEthCrossChainManager();
    //vm.stopPrank();
 }
}

contract ZilBridgeVanillaTests is ZilBridgeFixture {
  function test_ZilBridgeDeploy() external {
    setUp();
    deployOriginalContracts();
    require(ccmProxy.getEthCrossChainManager() == address(ccm));
    require(ccm.owner() == address(ccmProxy));
    require(ccmProxy.owner() == owner);
  }

  function test_ZilBridgeUpgrade() external {
    setUp();
    deployOriginalContracts();
    installExtendCrossChainManager(owner);
    //require(ccmProxy.getEthCrossChainManager() == address(extendCCM));
    //require(extendCCM.originalCCM.address == address(ccm));
    //require(!ccm.paused());
    //require(extendCCM.proxyOwner() == address(ccmProxy));
    //require(ccm.owner() == address(ccmProxy));
  }
}
