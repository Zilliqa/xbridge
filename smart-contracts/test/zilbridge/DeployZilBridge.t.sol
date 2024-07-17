// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "contracts/zilbridge/1/lockProxy.sol";
import { TestingLockProxy } from "./TestingLockProxy.sol";
import { EthCrossChainManagerProxy } from "contracts/zilbridge/1/ccmProxy.sol";
import { EthCrossChainManager } from "contracts/zilbridge/1/ccmCrossChainManager.sol";
import { EthCrossChainData } from "contracts/zilbridge/1/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/zilbridge/2/ccmExtendCrossChainManager.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerDeployer } from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";

abstract contract ZilBridgeFixture is Tester, LockProxyTokenManagerDeployer {
  address owner = vm.createWallet("owner").addr;
  address tokenDeployer = vm.createWallet("tokenDeployer").addr;
  address other = vm.createWallet("other").addr;
  address third = vm.createWallet("third").addr;
  uint64 constant COUNTERPART_CHAIN_ID = 5;
  uint64 constant CHAIN_ID = 2;
 
  EthCrossChainManager ccm;
  EthCrossChainManagerProxy ccmProxy;
  EthCrossChainData eccd;
  TestingLockProxy lockProxy;
  EthExtendCrossChainManager extendCCM;

  
  function deployOriginalContracts() internal {
    vm.startPrank(owner);
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    console.log("deploy_as = %s", owner);
    eccd = new EthCrossChainData();
    ccm = new EthCrossChainManager(address(eccd), CHAIN_ID, a,b);
    ccmProxy = new EthCrossChainManagerProxy(address(ccm));
    // Now give the ccm to the ccmProxy
    ccm.transferOwnership(address(ccmProxy));
    // and give the data to the ccm.
    eccd.transferOwnership(address(ccm));
    lockProxy = new TestingLockProxy(address(ccmProxy), COUNTERPART_CHAIN_ID);
    vm.stopPrank();
  }

  function installExtendCrossChainManager(address act_as) internal {
    vm.startPrank(act_as);
    console.log("act_as = %s", act_as);
    address[] memory a = new address[](0);
    bytes[] memory b = new bytes[](0);
    extendCCM = new EthExtendCrossChainManager(address(eccd), 2, a, b);
    console.log("ccmProxy owner  = %s", ccmProxy.owner());
    console.log("ccmProxy ccm = %s", ccmProxy.getEthCrossChainManager());
    console.log("eccm owner = %s", ccm.owner());
    console.log("eccd owner = %s", eccd.owner());
    console.log("ccm = %s", address(ccm));
    ccmProxy.pauseEthCrossChainManager();
    extendCCM.transferOwnership(address(ccmProxy));
    require(ccmProxy.upgradeEthCrossChainManager(address(extendCCM)));
    ccmProxy.unpauseEthCrossChainManager();
    vm.stopPrank();
 }

  function setUpZilBridgeForTesting() internal {
    deployOriginalContracts();
    installExtendCrossChainManager(owner);
  }

  function installTokenManager(address lpTokenManager) internal {
    // Make it an extension
    vm.startPrank(owner);
    extendCCM.forciblyAddExtension(address(lockProxy), address(lpTokenManager), COUNTERPART_CHAIN_ID);
    vm.stopPrank();
  }

  function getLockProxy() public returns (TestingLockProxy) {
    return lockProxy;
  }

}

contract DeployZilBridgeTest is ZilBridgeFixture {
  function test_ZilBridgeDeploy() external {
    deployOriginalContracts();
    // The owner of the proxy is us
    require(ccmProxy.owner() == owner);
    // The ccmProxy's ccm is the ccm we installed.
    require(ccmProxy.getEthCrossChainManager() == address(ccm));
    // The owner of the ccm is the ccmProxy
    require(ccm.owner() == address(ccmProxy));
    // the eccd is installed
    require(ccm.EthCrossChainDataAddress() == address(eccd));
    // the eccd's owner is the ccm
    require(eccd.owner() == address(ccm));
  }

  function test_ZilBridgeUpgrade() external {
    deployOriginalContracts();
    installExtendCrossChainManager(owner);

    // The owner of the proxy is us
    require(ccmProxy.owner() == owner);
    // The ccmProxy's ccm is the new CCM
    require(ccmProxy.getEthCrossChainManager() == address(extendCCM));
    // The ccm's owner is the ccm Proxy
    require(extendCCM.owner() == address(ccmProxy));
    // The ccm's eccd is intact
    require(extendCCM.EthCrossChainDataAddress() == address(eccd));
    // The eccd's owner is the ccm.
    require(eccd.owner() == address(extendCCM));

    // We're unpaused
    require(!extendCCM.paused());
    require(!ccmProxy.paused());
  }



  function test_installTokenManager() external {
    deployOriginalContracts();
    installExtendCrossChainManager(owner);
  }
}
