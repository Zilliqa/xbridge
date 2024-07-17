// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MintAndBurnTokenManagerUpgradeable} from "contracts/periphery/MintAndBurnTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { ERC20 } from "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import "forge-std/console.sol";

contract MyERC20 is ERC20 {
constructor(string memory name_, string memory symbol_, uint256 supply_) ERC20(name_, symbol_) {
    _mint(address(msg.sender), supply_);
  }
}


contract Deployment is Script {
  function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address owner = vm.addr(deployerPrivateKey);
        console.log("Owner is %s", owner);

        vm.startBroadcast(deployerPrivateKey);
        // Address of the ZilBridge tokenmanager
        // address tokenManagerAddress = 0x103617938D41f7bea62F0B5b4E8e50585083048F;
        // Address of the lock proxy
        address lockProxyAddress = 0x218D8aFE24bb2a0d1DE483Ff67aCADB45Ac8Bd2d;

        // The other half of these tokens are deployed via the scilla-contracts/scripts/deploy.ts script.

        // Native on BSC
        uint256 totalSupply = 1_000_000;
        string memory tokenName = "XTST_token";
        string memory tokenSymbol = "XTST";
        MyERC20 theContract = new MyERC20(tokenName, tokenSymbol, totalSupply);
        console.log("ERC20: %s", address(theContract));

        // Native on Zilliqa
        SwitcheoToken bridgedFromZilliqa = new SwitcheoToken(lockProxyAddress, "Bridged ZTST", "eZTST", 18);
        console.log("BridgedZRC2FromZilliqa: %s", address(bridgedFromZilliqa));

        // Bridged ZIL
        SwitcheoToken bridgedZIL = new SwitcheoToken(lockProxyAddress, "eZIL", "Bridged ZIL", 12);
        console.log("BridgedZIL: %s", address(bridgedZIL));
  }
}
