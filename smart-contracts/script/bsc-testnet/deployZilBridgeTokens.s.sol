// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";
import { TestnetConfig } from "script/testnetConfig.s.sol";

contract MyERC20 is ERC20 {
constructor(string memory name_, string memory symbol_, uint256 supply_) ERC20(name_, symbol_) {
    _mint(address(msg.sender), supply_);
  }
 function decimals() public pure override returns (uint8) {
   return 3;
 }
}


contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(deployerPrivateKey);
        // The other half of these tokens are deployed via the scilla-contracts/scripts/deploy.ts script.

        // Native on BSC
        uint256 totalSupply = 1_000_000_000;
        string memory tokenName = "XTST_token";
        string memory tokenSymbol = "XTST";
        MyERC20 theContract = new MyERC20(tokenName, tokenSymbol, totalSupply);
        console.log(
            "    address public constant bscERC20Address = %s", address(theContract));

        // Native on Zilliqa
        SwitcheoToken bridgedFromZilliqa = new SwitcheoToken(bscLockProxyAddress, "Bridged ZTST", "eZTST", 3);
        console.log(
            "    address public constant bscBridgedZRC2Address = %s", address(bridgedFromZilliqa));

        // Bridged ZIL
        SwitcheoToken bridgedZIL = new SwitcheoToken(bscLockProxyAddress, "eZIL", "Bridged ZIL", 12);
        console.log(
            "    address public constant bscBridgedZILAddress = %s", address(bridgedZIL));
  }
}
