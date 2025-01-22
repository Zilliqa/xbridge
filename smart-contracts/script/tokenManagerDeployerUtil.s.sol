// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/LockAndReleaseTokenManagerUpgradeableV2.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";

contract TokenManagerDeployerUtil {
  // The way that we do upgradeable contracts means that we need to (or at least, should) upgrade through all the versions in order to
  // initialise storage in case future contracts use it.
  function deployLockAndReleaseOrNativeTokenManager(address chainGateway, uint fees) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV3) {
    address implementation = address(new LockAndReleaseTokenManagerUpgradeable());
    address proxy = address(new ERC1967Proxy(implementation,
                                             abi.encodeCall(
                                                 LockAndReleaseTokenManagerUpgradeable.initialize,
                                                 chainGateway)));
    address newImplementation = address(new LockAndReleaseTokenManagerUpgradeableV2());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockAndReleaseTokenManagerUpgradeableV2.reinitialize, fees);
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newImplementation, encodedInitializerCall);
    address newNewImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV3());
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newNewImplementation, "");
    return LockAndReleaseOrNativeTokenManagerUpgradeableV3(payable(address(proxy)));
  }

  function deployLockProxyTokenManager(address chainGateway, uint fees) public returns (LockProxyTokenManagerUpgradeableV3) {
    address implementation = address(new LockAndReleaseTokenManagerUpgradeable());
    address proxy = address(new ERC1967Proxy(implementation,
                                             abi.encodeCall(
                                                 LockAndReleaseTokenManagerUpgradeable.initialize,
                                                 chainGateway)));
    // Thanks to the way the contracts are constructed, we can do this in "only" two steps.
    address newImplementation = address(new LockProxyTokenManagerUpgradeableV3());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockProxyTokenManagerUpgradeableV3.reinitialize, fees);
    LockAndReleaseTokenManagerUpgradeable(proxy).upgradeToAndCall(newImplementation, encodedInitializerCall);
    return LockProxyTokenManagerUpgradeableV3(payable(address(proxy)));
  }
}
