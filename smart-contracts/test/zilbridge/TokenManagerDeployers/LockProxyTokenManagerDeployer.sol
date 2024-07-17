// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeable.sol";
import { ZilliqaLockProxyTokenManagerUpgradeableV3 } from "contracts/zilbridge/2/ZilliqaLockProxyManagerUpgradeableV3.sol";

abstract contract LockProxyTokenManagerDeployer {

  // This is rather spurious, but serves to prove (albeit lightly!) that we could upgrade if we wanted to.
  function deployLockProxyTokenManagerUpgradeable(address chainGateway, address lockProxyAddress) public returns (LockProxyTokenManagerUpgradeable) {
    address implementation = address(new LockProxyTokenManagerUpgradeable());
    // Deploy proxy and attach our initial implementation.
    address proxy = address(
        new ERC1967Proxy(implementation, abi.encodeCall(LockProxyTokenManagerUpgradeable.initialize, (chainGateway, lockProxyAddress))));
    return LockProxyTokenManagerUpgradeable(proxy);
  }

  function deployLockProxyTokenManagerV3(
      address chainGateway,
      address lockProxyAddress,
      uint fees) public returns (LockProxyTokenManagerUpgradeableV3) {
    LockProxyTokenManagerUpgradeable proxy = deployLockProxyTokenManagerUpgradeable(chainGateway, lockProxyAddress);
    address newImplementation = address(new LockProxyTokenManagerUpgradeableV3());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockProxyTokenManagerUpgradeableV3.reinitialize, fees);
    proxy.upgradeToAndCall(newImplementation, encodedInitializerCall);
    return LockProxyTokenManagerUpgradeableV3(address(proxy));
  }

  function deployZilliqaLockProxyTokenManagerV3(
      address chainGateway,
      address lockProxyAddress,
      uint fees) public returns (ZilliqaLockProxyTokenManagerUpgradeableV3) {
    LockProxyTokenManagerUpgradeable proxy = deployLockProxyTokenManagerUpgradeable(chainGateway, lockProxyAddress);
    address newImplementation = address(new ZilliqaLockProxyTokenManagerUpgradeableV3());
    bytes memory encodedInitializerCall = abi.encodeCall(
        ZilliqaLockProxyTokenManagerUpgradeableV3.reinitialize, fees);
    proxy.upgradeToAndCall(newImplementation, encodedInitializerCall);
    return ZilliqaLockProxyTokenManagerUpgradeableV3(address(proxy));
  }

  function deployLatestLockProxyTokenManager(address chainGateway, address lockProxy, uint fees) public returns (LockProxyTokenManagerUpgradeableV3) {
    return deployLockProxyTokenManagerV3(chainGateway, lockProxy, fees);
  }

  function deployLatestZilliqaLockProxyTokenManager(address chainGateway, address lockProxy, uint fees) public returns (ZilliqaLockProxyTokenManagerUpgradeableV3) {
    return deployZilliqaLockProxyTokenManagerV3(chainGateway, lockProxy, fees);
  }

}