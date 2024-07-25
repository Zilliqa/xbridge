pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {LockAndReleaseTokenManagerUpgradeable} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseOrNativeTokenManagerUpgradeableV3.sol";
import {ITokenManagerStructs, ITokenManager} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ZRC2ProxyForZRC2} from "test/zilbridge/zrc2erc20/ZRC2ProxyForZRC2.sol";
import "forge-std/console.sol";
import "script/testnet_config.s.sol";
import {IERC20} from "contracts/periphery/LockAndReleaseTokenManagerUpgradeable.sol";
import {IRelayer, Relayer, CallMetadata} from "contracts/core/Relayer.sol";
import {Registry} from "contracts/core/Registry.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";

contract Deployment is Script, TestnetConfig {
  function run() external {
    //        uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_ZILBRIDGE");
    uint256 validatorPrivateKey = vm.envUint("PRIVATE_KEY_TESTNET");

        address validator = vm.addr(validatorPrivateKey);
        vm.startBroadcast(validatorPrivateKey);
        console.log("I am %s", validator);
        console.log("Token manager at %s", zq_lockAndReleaseOrNativeTokenManager);
        console.log("ChainGateway %s", zq_chainGateway);
        ChainGateway chainGateway = ChainGateway(zq_chainGateway);
        chainGateway.register(address(zq_lockAndReleaseOrNativeTokenManager));
        console.log(
            "TokenManager %s registered to %s ChainGateway: %s",
            address(zq_lockAndReleaseOrNativeTokenManager),
            address(chainGateway),
            chainGateway.registered(address(zq_lockAndReleaseOrNativeTokenManager))
        );

        Relayer relayer = Relayer(zq_chainGateway);
        bool amRegistered = relayer.registered(zq_lockAndReleaseOrNativeTokenManager);
        console.log("isRegistered %d", amRegistered);
        
        
        /* ITokenManager tok = ITokenManager(zq_lockAndReleaseOrNativeTokenManager); */
        /* ITokenManagerStructs.RemoteToken memory rt = tok.getRemoteTokens(0x2A82a13A118c0f9E203a9C006742024354D0f4Ca, 97); */
        /* console.log("remoteToken = %s / mgr %s / chainId %d", rt.token, rt.tokenManager, rt.chainId); */
        /* // Now find out what our balance of local tokens is.. */
        /* ERC20 nativeToken = ERC20(zq_zrc2_evm); */
        /* ZRC2ProxyForZRC2 proxy = ZRC2ProxyForZRC2(zq_zrc2_evm); */
        /* uint256 bal = nativeToken.balanceOf(validator); */
        /* console.log("my balance of %s is %d", zq_zrc2_evm, bal); */
        /* console.log("for %s", validator); */
        /* uint256 bal2 = proxy.balanceOf(address(0x003ceb00d128fc46adda183aa9e4dd832af2b3dfe3)); */
        /* console.log("or %d", bal2); */
        /* console.log("%s proxies .. ", zq_zrc2_evm); */
        /* console.log("  ... to zrc2 %s", proxy.zrc2_proxy()); */
        /* console.log("  ... decimals %d", proxy.decimals()); */
        /* console.log("  ... symbol %s", proxy.symbol()); */
        // Fails, so...
        //console.log("Transfer .. ");
        //nativeToken.transfer(address(0x00b85ff091342e2e7a7461238796d5224fa81ca556), 1);

        /* console.log("Deploying proxy for %s",address(zq_zrc2)); */
        /* ZRC2ProxyForZRC2 proxy2 = new ZRC2ProxyForZRC2(zq_zrc2); */
        /* console.log("new ZRC2 proxy %s", address(proxy2)); */
        /* vm.stopBroadcast(); */
        /* uint256 bal3 = proxy2.balanceOf(validator); */
        /* console.log("proxy2 balance %d", bal3); */
        
  }

}
