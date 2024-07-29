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

/*** @notice does what ZilBridgeFixture::deployOriginalContracts() does */
contract deployMockZilBridge is Script, TestnetConfig {
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
    console.log(
        "    address public constant bscEthCrossChainDataAddress = %s", address(eccd));
    ccm = new EthCrossChainManager(address(eccd), zbBscChainId, a, b);
    console.log(
        "    address public constant bscCCMAddress = %s", address(ccm));
    ccmProxy = new EthCrossChainManagerProxy(address(ccm));
    console.log(
        "    address public constant bscCCMProxyAddress = %s", address(ccmProxy));
    ccm.transferOwnership(address(ccmProxy));
    eccd.transferOwnership(address(ccm));
    lockProxy = new LockProxy(address(ccmProxy), zbZilliqaChainId);
    console.log(
        "      address public constant bscLockProxyAddress = %s", address(lockProxy));
  }
}
