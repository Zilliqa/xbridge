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

/*** @notice Deploy token managers over the extension manager
 */
contract deployZilBridgeTokenManagers is Script, LockProxyTokenManagerDeployer {
  EthExtendCrossChainManager constant extendCCM = EthExtendCrossChainManager(0xF2eeaceDB35776412fe999D45aA81Ea674030aE1);
  ChainGateway constant chainGateway = ChainGateway(0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE);
  LockProxy constant lockProxy = LockProxy(payable(0x218D8aFE24bb2a0d1DE483Ff67aCADB45Ac8Bd2d));
  // Different from 0.00025 so that we can tell the difference!
  uint fees = 0.00007 ether;

  // This has to be 18, because that is what the original (ZilBridge) contracts were
  // deployed with. The mainnet value is 5.
  uint64 constant COUNTERPART_CHAIN_ID = 18;

  function run() external {
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_VALIDATOR");
    uint256 bridgePrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    address validator = vm.addr(validatorPrivateKey);
    address bridgeOwner = vm.addr(bridgePrivateKey);
    // token managers are apparently not pausable, so ..
    vm.startBroadcast(validatorPrivateKey);
    LockProxyTokenManagerUpgradeableV3 tokenManager = deployLatestLockProxyTokenManager(address(chainGateway), address(lockProxy), fees);
    console.log("zilbridge tokenmanager: %s", address(tokenManager));
    vm.stopBroadcast();
    vm.startBroadcast(bridgePrivateKey);
    extendCCM.forciblyAddExtension(address(lockProxy), address(tokenManager), COUNTERPART_CHAIN_ID);
    vm.stopBroadcast();
    vm.startBroadcast(validatorPrivateKey);
    chainGateway.register(address(tokenManager));
    vm.stopBroadcast();
  }
}
