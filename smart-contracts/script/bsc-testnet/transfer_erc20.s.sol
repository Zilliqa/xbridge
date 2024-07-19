pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "forge-std/console.sol";
import "script/testnet_config.s.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");
        address validator = vm.addr(validatorPrivateKey);
        console.log("Owner is %s", validator);
        vm.startBroadcast(validatorPrivateKey);
        ERC20 theContract = ERC20(bsc_erc20);
        // rrw's address for testing.
        theContract.transfer( 0x8E5b86101456ec8bCd213C07c47E8B2006C93608 , 500_000);
  }

}
