// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

// ZilBridge-remote chains have:
//  - A LockProxyTokenManagerUpgradeable which mints and burns tokens bridged from Zilliqa
//  - A LockAndReleaseOrNativeTokenManager which holds tokens bridged to Zilliqa.
//
// The token managers need to be registered with the chain gateway and routing set up.
// For "new" chains (eth, arb, pol) this is done in the deployment scripts.
// For chains where control has been handed to the custodians, we need to generate txns and then
//  have them approved via the internal management interface.

import {Script} from "forge-std/Script.sol";
import "forge-std/console.sol";
import { ChainGateway } from "contracts/core/ChainGateway.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";
import { LockAndReleaseOrNativeTokenManagerUpgradeableV3 } from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import { LockProxyTokenManagerUpgradeableV3 } from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import { MainnetConfig } from "script/testnetConfig.s.sol";

contract deployZilBridgeTokenManagers is Script, MainnetConfig {


}
