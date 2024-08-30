// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/LockAndReleaseTokenManagerUpgradeableV2.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
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

    function deployLatestLockAndReleaseOrNativeTokenManager(
        address chainGateway,
        uint fees
    ) public returns (LockAndReleaseOrNativeTokenManagerUpgradeableV3) {
        return deployLockAndReleaseOrNativeTokenManagerV3(chainGateway, fees);
    }
}
