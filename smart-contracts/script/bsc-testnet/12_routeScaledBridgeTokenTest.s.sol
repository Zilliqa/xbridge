// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(validatorPrivateKey);
        LockAndReleaseOrNativeTokenManagerUpgradeableV4 zilliqaTokenManager = LockAndReleaseOrNativeTokenManagerUpgradeableV4(payable(zqLockAndReleaseOrNativeTokenManagerAddress));
        LockProxyTokenManagerUpgradeableV4 bscTokenManager = LockProxyTokenManagerUpgradeableV4(bscLockProxyTokenManagerAddress);

        // On BSC, the scale is 8
        // on Zilliqa, the scale is 18

        // when bscBridgedScaledToken arrives at bscTokenManager, send it to zilliqaTokenManager as zqScaledTokenERC20Address with a scale of +10
        ITokenManagerStructs.RemoteToken memory router = ITokenManagerStructs.RemoteToken({
         token: address(zqScaledTokenERC20Address),
         tokenManager: address(zilliqaTokenManager),
         chainId: zqChainId});
        
        bscTokenManager.registerTokenWithScale(address(bscBridgedScaledTokenAddress), router, 10);
  }
}
