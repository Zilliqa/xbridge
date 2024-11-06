// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerUpgradeable} from "contracts/periphery/LockProxyTokenManagerUpgradeable.sol";

abstract contract LockProxyTokenManagerDeployer {

  // This is rather spurious, but serves to prove (albeit lightly!) that we could upgrade if we wanted to.
  function deployLockProxyTokenManagerUpgradeable(address chainGateway, address lockProxyAddress, address lockProxyProxyAddress) public returns (LockProxyTokenManagerUpgradeable) {
    address implementation = address(new LockProxyTokenManagerUpgradeable());
    // Deploy proxy and attach our initial implementation.
    address proxy = address(
        new ERC1967Proxy(implementation, abi.encodeCall(LockProxyTokenManagerUpgradeable.initialize, (chainGateway, lockProxyAddress, lockProxyProxyAddress))));
    return LockProxyTokenManagerUpgradeable(proxy);
  }

  function deployLockProxyTokenManagerV3(
      address chainGateway,
      address lockProxyAddress,
      address lockProxyProxyAddress,
      uint fees) public returns (LockProxyTokenManagerUpgradeableV3) {
    LockProxyTokenManagerUpgradeable proxy = deployLockProxyTokenManagerUpgradeable(chainGateway, lockProxyAddress, lockProxyProxyAddress);
    address newImplementation = address(new LockProxyTokenManagerUpgradeableV3());
    bytes memory encodedInitializerCall = abi.encodeCall(
        LockProxyTokenManagerUpgradeableV3.reinitialize, fees);
    proxy.upgradeToAndCall(newImplementation, encodedInitializerCall);
    return LockProxyTokenManagerUpgradeableV3(address(proxy));
  }

  function deployLatestLockProxyTokenManager(address chainGateway, address lockProxy, address lockProxyProxy, uint fees) public returns (LockProxyTokenManagerUpgradeableV3) {
    return deployLockProxyTokenManagerV3(chainGateway, lockProxy, lockProxyProxy, fees);
  }
}
