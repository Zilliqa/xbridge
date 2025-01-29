// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {MintAndBurnTokenManagerUpgradeableV2} from "contracts/periphery/TokenManagerV2/MintAndBurnTokenManagerUpgradeableV2.sol";
import {MintAndBurnTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/MintAndBurnTokenManagerUpgradeableV3.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {MintAndBurnTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/MintAndBurnTokenManagerUpgradeableV5.sol";
import {MintAndBurnTokenManagerUpgradeableV6} from "contracts/periphery/TokenManagerV6/MintAndBurnTokenManagerUpgradeableV6.sol";

abstract contract MintAndBurnTokenManagerDeployer {
    function deployMintAndBurnTokenManagerV1(
        address chainGateway
    ) public returns (MintAndBurnTokenManagerUpgradeable) {
        address implementation = address(
            new MintAndBurnTokenManagerUpgradeable()
        );
        // Deploy proxy and attach v1
        address proxy = address(
            new ERC1967Proxy(
                implementation,
                abi.encodeCall(
                    MintAndBurnTokenManagerUpgradeable.initialize,
                    chainGateway
                )
            )
        );

        return MintAndBurnTokenManagerUpgradeable(proxy);
    }

    function deployMintAndBurnTokenManagerV2(
        address chainGateway,
        uint fees
    ) public returns (MintAndBurnTokenManagerUpgradeableV2) {
        MintAndBurnTokenManagerUpgradeable proxy = deployMintAndBurnTokenManagerV1(
                chainGateway
            );

        address newImplementation = address(
            new MintAndBurnTokenManagerUpgradeableV2()
        );

        bytes memory encodedInitializerCall = abi.encodeCall(
            MintAndBurnTokenManagerUpgradeableV2.reinitialize,
            fees
        );
        proxy.upgradeToAndCall(newImplementation, encodedInitializerCall);

        return MintAndBurnTokenManagerUpgradeableV2(address(proxy));
    }

    function deployMintAndBurnTokenManagerV3(
        address chainGateway,
        uint fees
    ) public returns (MintAndBurnTokenManagerUpgradeableV3) {
        MintAndBurnTokenManagerUpgradeableV2 proxy = deployMintAndBurnTokenManagerV2(
                chainGateway,
                fees
            );

        address newImplementation = address(
            new MintAndBurnTokenManagerUpgradeableV3()
        );

        proxy.upgradeToAndCall(newImplementation, "");

        return MintAndBurnTokenManagerUpgradeableV3(address(proxy));
    }

    function deployMintAndBurnTokenManagerV4(
        address chainGateway,
        uint fees
    ) public returns (MintAndBurnTokenManagerUpgradeableV4) {
      MintAndBurnTokenManagerUpgradeableV3 proxy = deployMintAndBurnTokenManagerV3(
          chainGateway,
          fees
       );
      address newImplementation = address(
          new MintAndBurnTokenManagerUpgradeableV4()
      );
      proxy.upgradeToAndCall(newImplementation, "");
      return MintAndBurnTokenManagerUpgradeableV4(address(proxy));
    }

    function deployMintAndBurnTokenManagerV5(
        address chainGateway,
        uint fees
     ) public returns (MintAndBurnTokenManagerUpgradeableV5) {
      MintAndBurnTokenManagerUpgradeableV3 proxy = deployMintAndBurnTokenManagerV3(
          chainGateway, fees);
      // We can go straight to v5.
      address newImplementation = address(
          new MintAndBurnTokenManagerUpgradeableV5()
                                          );
      proxy.upgradeToAndCall(newImplementation, "");
      return MintAndBurnTokenManagerUpgradeableV5(address(proxy));
    }

    function deployMintAndBurnTokenManagerV6(
        address chainGateway,
        uint fees
     ) public returns (MintAndBurnTokenManagerUpgradeableV6) {
      MintAndBurnTokenManagerUpgradeableV3 proxy = deployMintAndBurnTokenManagerV3(
          chainGateway, fees);
      // We can go straight to v6.
      address newImplementation = address(
          new MintAndBurnTokenManagerUpgradeableV6()
                                          );
      proxy.upgradeToAndCall(newImplementation, "");
      return MintAndBurnTokenManagerUpgradeableV6(address(proxy));
    }

    function deployLatestMintAndBurnTokenManager(
        address chainGateway,
        uint fees
    ) public returns (MintAndBurnTokenManagerUpgradeableV6) {
       return deployMintAndBurnTokenManagerV6(chainGateway, fees);
    }
}
