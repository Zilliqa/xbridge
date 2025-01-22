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
   return 18;
 }
}


contract Deployment is Script, TestnetConfig {
  uint256 constant ONE_UNIT = 1_000_000_000_000_000_000;
  
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(deployerPrivateKey);
        // The other half of these tokens are deployed via the scilla-contracts/scripts/deploy.ts script.

        // Native on Zilliqa
        uint256 totalSupply = 1_000_000_000 * ONE_UNIT;
        string memory tokenName = "SCALED";
        string memory tokenSymbol = "SCLD";
        MyERC20 theContract = new MyERC20(tokenName, tokenSymbol, totalSupply);
        console.log(
            "    address public constant zqScaledTokenERC20Address = %s", address(theContract));
  }
}
