// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import {Tester} from "test/Tester.sol";
import {TestToken} from "test/Helpers.sol";
import { LockProxy } from "test/zilbridge/infrastructure/lockProxy.sol";
import { TestingLockProxy } from "test/zilbridge/TestingLockProxy.sol";
import { EthCrossChainManagerProxy } from "test/zilbridge/infrastructure/ccmProxy.sol";
import { EthCrossChainManager } from "test/zilbridge/infrastructure/ccmCrossChainManager.sol";
import { EthCrossChainData } from "test/zilbridge/infrastructure/ethCrossChainData.sol";
import { EthExtendCrossChainManager } from "contracts/periphery/ZilBridge/ccmExtendCrossChainManager.sol";
import { ChainGateway } from "contracts/core/ChainGateway.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerDeployer } from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerDeployer} from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {MintAndBurnTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/MintAndBurnTokenManagerDeployer.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

/*** @notice Deploy token managers over the extension manager
 */
contract deployZilBridgeTokenManagers is Script, LockProxyTokenManagerDeployer, TestnetConfig {
  EthExtendCrossChainManager constant extendCCM = EthExtendCrossChainManager(bscExtendCCMAddress);
  ChainGateway constant chainGateway = ChainGateway(bscChainGatewayAddress);
  LockProxy constant lockProxy = LockProxy(payable(bscLockProxyAddress));
  // Different from 0.00025 so that we can tell the difference!
  uint fees = 0.00007 ether;

  // This has to be 18, because that is what the original (ZilBridge) contracts were
  // deployed with. The mainnet value is 5.
  uint64 constant COUNTERPART_CHAIN_ID = zbZilliqaChainId;

  function run() external {
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
    uint256 bridgePrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    // token managers are apparently not pausable, so ..
    vm.startBroadcast(validatorPrivateKey);
    address[] memory allowedTokens = new address[](3);
    allowedTokens[0] = bscERC20Address;
    allowedTokens[1] = bscBridgedZRC2Address;
    allowedTokens[2] = bscBridgedZILAddress;
    LockProxyProxy lockProxyProxy = new LockProxyProxy(allowedTokens, vm.addr(validatorPrivateKey), address(lockProxy));
    LockProxyTokenManagerUpgradeableV3 tokenManager = deployLockProxyTokenManagerV3(address(chainGateway), address(lockProxy), address(lockProxyProxy), fees);
    lockProxyProxy.addCaller(address(tokenManager));
    console.log(
        "    address public constant bscLockProxyTokenManagerAddress =  %s", address(tokenManager));
    vm.stopBroadcast();
    vm.startBroadcast(bridgePrivateKey);
    extendCCM.forciblyAddExtension(address(lockProxyProxy), address(tokenManager), COUNTERPART_CHAIN_ID);
    vm.stopBroadcast();
    vm.startBroadcast(validatorPrivateKey);
    chainGateway.register(address(tokenManager));
    vm.stopBroadcast();
  }
}
