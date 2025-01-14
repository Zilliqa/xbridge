// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/LockAndReleaseTokenManagerUpgradeableV2.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";
import {LockAndReleaseTokenManagerDeployer} from "./LockAndReleaseTokenManagerDeployer.sol";

abstract contract LockAndReleaseOrNativeTokenManagerDeployer is
    LockAndReleaseTokenManagerDeployer {
    function deployLockAndReleaseOrNativeTokenManagerV3(
        address chainGateway,
        uint fees
    ) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV3) {
        LockAndReleaseTokenManagerUpgradeableV2 proxy = deployLockAndReleaseTokenManagerV2(
                chainGateway,
                fees
            );

        address newImplementation = address(
            new LockAndReleaseOrNativeTokenManagerUpgradeableV3()
        );

        proxy.upgradeToAndCall(newImplementation, "");

        return LockAndReleaseOrNativeTokenManagerUpgradeableV3(payable(address(proxy)));
    }

    // Named like this to prevent those who we don't want to have access constructing one.
    // You should be using V5.
    function deployLockAndReleaseOrNativeTokenManagerV4x(
        address chainGateway,
        uint fees
     ) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV4) {
      LockAndReleaseOrNativeTokenManagerUpgradeableV3 proxy = deployLockAndReleaseOrNativeTokenManagerV3(
          chainGateway,
          fees);
      address newImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV4());
      proxy.upgradeToAndCall(newImplementation, "");
      return LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(address(proxy)));
    }

    function deployLockAndReleaseOrNativeTokenManagerV5(
        address chainGateway,
        uint fees
     ) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV5) {
      // We can upgrade direct from V3 to V5
      LockAndReleaseOrNativeTokenManagerUpgradeableV3 proxy = deployLockAndReleaseOrNativeTokenManagerV3(
          chainGateway,
          fees);
      address newImplementation = address(new LockAndReleaseOrNativeTokenManagerUpgradeableV5());
      proxy.upgradeToAndCall(newImplementation, "");
      return LockAndReleaseOrNativeTokenManagerUpgradeableV5(payable(address(proxy)));
    }

    function deployLatestLockAndReleaseOrNativeTokenManager(
        address chainGateway,
        uint fees
    ) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV5) {
        return deployLockAndReleaseOrNativeTokenManagerV5(chainGateway, fees);
    }
}
