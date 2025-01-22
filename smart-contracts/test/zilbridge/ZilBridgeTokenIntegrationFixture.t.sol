// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester, Vm} from "test/Tester.sol";
import {ITokenManagerStructs, TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseOrNativeTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockAndReleaseOrNativeTokenManagerUpgradeableV4.sol";
import {MintAndBurnTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/MintAndBurnTokenManagerUpgradeableV4.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";
import {CallMetadata, IRelayerEvents} from "contracts/core/Relayer.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {TestToken} from "test/Helpers.sol";
import {LockProxyTokenManagerUpgradeableV4} from "contracts/periphery/TokenManagerV4/LockProxyTokenManagerUpgradeableV4.sol";
import {LockProxyTokenManagerDeployer} from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {MintAndBurnTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/MintAndBurnTokenManagerDeployer.sol";
import {LockAndReleaseOrNativeTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseOrNativeTokenManagerDeployer.sol";
import { SwitcheoToken } from "test/zilbridge/tokens/switcheo/tokens/SwitcheoTokenETH.sol";
import { ZilBridgeFixture } from "test/zilbridge/DeployZilBridge.t.sol";
import { MockLockProxy } from "./MockLockProxy.sol";


/*** @notice This deploys a bridge that is ZilBridge token manager on one side and lock-and-release on the other.
 * We do this so we can test ZilBridge integration end to end, though in fact the "other side" of the bridge will be provided
 * by the code in the Scilla half of this repo.
 *
 * Since the word "native" is quite heavily overloaded, we use "gas" to describe the gas token - ETH on ethereum, for example.
 */
contract ZilBridgeTokenBridgeIntegrationFixture is
Tester, IRelayerEvents, LockAndReleaseOrNativeTokenManagerDeployer, LockProxyTokenManagerDeployer, ZilBridgeFixture {
  using MessageHashUtils for bytes;

  // Gateway shared between the two chains
  Vm.Wallet validatorWallet = vm.createWallet(1);
  address validator = validatorWallet.addr;
  address[] validators = [ validator ];
  address sourceUser = vm.addr(2);
  address remoteUser = vm.addr(3);
  uint originalTokenSupply = 1000 ether;
  uint fees = 0.1 ether;

  LockProxyTokenManagerUpgradeableV4 sourceTokenManager;
  LockProxyProxy lockProxyProxy;

  // There are "actually" three of these - native (which is lock/release), a mint/burn token and a conventional token.
  // This means we need a remote lock manager and a remote mint burn manager.
  TestToken nativelyOnSource;
  SwitcheoToken sourceNativelyOnRemote;
  ChainGateway sourceChainGateway;
  ValidatorManager sourceValidatorManager;

  // see doc/zilbridge.md
  MockLockProxy mockRemoteLockProxy;
  LockProxyProxy remoteLockProxyProxy;
  LockProxyTokenManagerUpgradeableV4 remoteTokenManager;
  SwitcheoToken remoteNativelyOnSource;
  SwitcheoToken remoteBridgedGasToken;
  TestToken nativelyOnRemote;

  ChainGateway remoteChainGateway;
  ValidatorManager remoteValidatorManager;

  function installContracts() public {
    setUpZilBridgeForTesting();

    vm.startPrank(validator);
    // Deploy source infra
    sourceValidatorManager = new ValidatorManager(validator);
    sourceValidatorManager.initialize(validators);
    sourceChainGateway = new ChainGateway(address(sourceValidatorManager), validator);

    // Deploy target infra
    remoteValidatorManager = new ValidatorManager(validator);
    remoteValidatorManager.initialize(validators);
    remoteChainGateway = new ChainGateway(address(remoteValidatorManager), validator);

    // Deploy the tokens
    nativelyOnSource = new TestToken(originalTokenSupply);
    mockRemoteLockProxy = new MockLockProxy();
    remoteNativelyOnSource = new SwitcheoToken(address(mockRemoteLockProxy), "Bridged testToken", "eTST", 18);
    remoteBridgedGasToken = new SwitcheoToken(address(mockRemoteLockProxy), "Bridged gas", "eGAS", 18);
    sourceNativelyOnRemote = new SwitcheoToken(address(lockProxy), "Back-ported test token", "bTST", 18);
    nativelyOnRemote = new TestToken(originalTokenSupply);

    address[] memory locallyPermittedTokens = new address[](3);
    locallyPermittedTokens[0] = address(sourceNativelyOnRemote);
    locallyPermittedTokens[1] = address(nativelyOnSource);
    locallyPermittedTokens[2] = address(0);
    console.log("locallyPermittedTokens = %s %s %s", address(sourceNativelyOnRemote), address(nativelyOnSource), address(0));
    lockProxyProxy = new LockProxyProxy(locallyPermittedTokens, validator, address(lockProxy));

    address[] memory remotelyPermittedTokens = new address[](3);
    remotelyPermittedTokens[0] = address(remoteNativelyOnSource);
    remotelyPermittedTokens[1] = address(remoteBridgedGasToken);
    remotelyPermittedTokens[2] = address(nativelyOnRemote);
    console.log("remotelyPermittedTokens = %s %s", address(remoteNativelyOnSource), address(remoteBridgedGasToken), address(nativelyOnRemote));
    remoteLockProxyProxy = new LockProxyProxy(remotelyPermittedTokens, validator, address(mockRemoteLockProxy));

    // Deploy the token managers
    sourceTokenManager = deployLatestLockProxyTokenManager(address(sourceChainGateway), address(lockProxy), address(lockProxyProxy), fees);
    remoteTokenManager = deployLatestLockProxyTokenManager(address(remoteChainGateway), address(mockRemoteLockProxy), address(remoteLockProxyProxy), fees);

    // Allow them to access the LPP
    lockProxyProxy.addCaller(address(sourceTokenManager));
    remoteLockProxyProxy.addCaller(address(remoteTokenManager));

    vm.stopPrank();
    // Make the token manager an extension.
    installLockProxyProxy(address(lockProxyProxy));
    // No need for remoteLockProxyProxy, since that's talking to a MockLockProxy which doesn't validate its
    // caller.

    // That involved a prank, so we need to reset our caller to the validator.
    vm.startPrank(validator);

    // Register contracts to chaingateway
    sourceChainGateway.register(address(sourceTokenManager));
    remoteChainGateway.register(address(remoteTokenManager));

    // Deploy the test tokens.
    nativelyOnSource.transfer(sourceUser, originalTokenSupply);

    // When coins arrive at the remote token manager for remoteNativelyOnSource, send them to nativelyOnSource's
    // manager at sourceTokenManager.
    ITokenManagerStructs.RemoteToken memory sourceNOSStruct = ITokenManagerStructs.RemoteToken({
     token: address(nativelyOnSource),
     tokenManager: address(sourceTokenManager),
     chainId: block.chainid });
    remoteTokenManager.registerToken(address(remoteNativelyOnSource), sourceNOSStruct);

    // When coins arrive at nativelyOnSource, send them to remoteNativelyOnSource's manager at remoteTokenManager
    ITokenManagerStructs.RemoteToken memory remoteNOSStruct = ITokenManagerStructs.RemoteToken({
     token: address(remoteNativelyOnSource),
     tokenManager: address(remoteTokenManager),
     chainId: block.chainid });
    sourceTokenManager.registerToken(address(nativelyOnSource), remoteNOSStruct);

    // Now, we'll do the gas token. This has to be a switcheo token, because
    // the other side can hardly be mint & burn.

    console.log("remoteBridgedGasToken = %s", address(remoteBridgedGasToken));
    console.log("mockLockProxy = %s", address(mockRemoteLockProxy));
    // When coins arrive at the remote token manager, send them to 0 on the source token manager.
    ITokenManagerStructs.RemoteToken memory sourceGasStruct = ITokenManagerStructs.RemoteToken({
     token: address(0),
     tokenManager: address(sourceTokenManager),
     chainId: block.chainid });
    remoteTokenManager.registerToken(address(remoteBridgedGasToken), sourceGasStruct);

    // When coins arrive at 0 on the source token manager, send them to remoteridgedGasToken on the remote
    ITokenManagerStructs.RemoteToken memory remoteGasStruct = ITokenManagerStructs.RemoteToken({
     token: address(remoteBridgedGasToken),
     tokenManager: address(remoteTokenManager),
     chainId: block.chainid });
    sourceTokenManager.registerToken(address(0), remoteGasStruct);

    nativelyOnRemote.transfer(remoteUser, originalTokenSupply);
    
    // When tokens arrive at the remote token manager, send them to the source
    ITokenManagerStructs.RemoteToken memory sourceBackStruct = ITokenManagerStructs.RemoteToken({
     token: address(sourceNativelyOnRemote),
     tokenManager: address(sourceTokenManager),
     chainId: block.chainid });
    remoteTokenManager.registerToken(address(nativelyOnRemote), sourceBackStruct);

    // When tokens arrive at the source token manager, send them to the remote
    ITokenManagerStructs.RemoteToken memory remoteBackStruct = ITokenManagerStructs.RemoteToken({
     token: address(nativelyOnRemote),
     tokenManager: address(remoteTokenManager),
     chainId: block.chainid });
    sourceTokenManager.registerToken(address(sourceNativelyOnRemote), remoteBackStruct);

    vm.stopPrank();
  }

}

