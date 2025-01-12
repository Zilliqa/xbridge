// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/LockAndReleaseTokenManagerUpgradeableV2.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";

contract TokenManagerDeployerUtilV4 {
  // The way that we do upgradeable contracts means that we need to (or at least, should) upgrade through all the versions in order to
  // initialise storage in case future contracts use it.
  // But gas is an issue, so we go straight from V2 -> V4 (V3 just changed to 2 step upgrade, which doesn't require a formal upgrade step)
  function deployLockAndReleaseOrNativeTokenManager(address chainGateway, uint fees) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV4) {
    address implementation = address(new LockAndReleaseTokenManagerUpgradeable());
    address proxy = address(new ERC1967Proxy(implementation,
                                             abi.encodeCall(
                                                 LockAndReleaseTokenManagerUpgradeable.initialize,
                                                 chainGateway)));
    address newImplementation = address(new LockAndReleaseTokenManagerUpgradeableV2());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockAndReleaseTokenManagerUpgradeableV2.reinitialize, fees);
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newImplementation, encodedInitializerCall);
    address newNewImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV4());
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newNewImplementation, "");
    return LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(address(proxy)));
  }

  function deployLockProxyTokenManager(address chainGateway, uint fees) public returns (LockProxyTokenManagerUpgradeableV4) {
    address implementation = address(new LockAndReleaseTokenManagerUpgradeable());
    address proxy = address(new ERC1967Proxy(implementation,
                                             abi.encodeCall(
                                                 LockAndReleaseTokenManagerUpgradeable.initialize,
                                                 chainGateway)));
    // Sadly, we have to do this in two stages too..
    address newImplementation = address(new LockProxyTokenManagerUpgradeableV3());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockProxyTokenManagerUpgradeableV3.reinitialize, fees);
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newImplementation, encodedInitializerCall);

    address newNewImplementation = address(new LockProxyTokenManagerUpgradeableV4());
    LockProxyTokenManagerUpgradeable(proxy).upgradeToAndCall(newNewImplementation, "");
    return LockProxyTokenManagerUpgradeableV4(payable(address(proxy)));
  }
}
