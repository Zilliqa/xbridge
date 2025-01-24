// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import { MainnetConfig } from "script/mainnetConfig.s.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV5} from "contracts/periphery/TokenManagerV5/LockAndReleaseOrNativeTokenManagerUpgradeableV5.sol";

/*** @title Route tokens from Base
 */
contract Deployment is Script, MainnetConfig {
  function run() external {
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_OWNER");
    address validator = vm.addr(validatorPrivateKey);
    console.log("Owner is %s", validator);

    vm.startBroadcast(validatorPrivateKey);
    LockAndReleaseOrNativeTokenManagerUpgradeableV5 zilliqaTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV5(payable(zilLockAndReleaseOrNativeTokenManagerUpgradeable));

    // When zqScaledTokenERC20Address turns up, route it to bscBridgedScaledToken with a scale of -10

    ITokenManagerStructs.RemoteToken memory router = ITokenManagerStructs.RemoteToken({
     token: address(baseHRSETokenAddress),
     tokenManager: address(baseMintAndBurnTokenManagerUpgradeable),
     chainId: baseChainId});
    zilliqaTokenManager.registerToken(address(zqHRSETokenAddress), router);
  }
}
