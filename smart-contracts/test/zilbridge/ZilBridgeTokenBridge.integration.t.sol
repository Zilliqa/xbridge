// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import "forge-std/console.sol";
import {Tester, Vm} from "test/Tester.sol";
import {ITokenManagerStructs, TokenManagerUpgradeable} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {LockAndReleaseTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/LockAndReleaseTokenManagerUpgradeableV3.sol";
import {MintAndBurnTokenManagerUpgradeableV3} from "contracts/periphery/TokenManagerV3/MintAndBurnTokenManagerUpgradeableV3.sol";
import {BridgedToken} from "contracts/periphery/BridgedToken.sol";
import {CallMetadata, IRelayerEvents} from "contracts/core/Relayer.sol";
import {ValidatorManager} from "contracts/core/ValidatorManager.sol";
import {ChainGateway} from "contracts/core/ChainGateway.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {TestToken} from "test/Helpers.sol";
import {LockProxyTokenManagerUpgradeableV3} from "contracts/zilbridge/2/LockProxyTokenManagerUpgradeableV3.sol";
import {LockProxyTokenManagerDeployer} from "test/zilbridge/TokenManagerDeployers/LockProxyTokenManagerDeployer.sol";
import {MintAndBurnTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/MintAndBurnTokenManagerDeployer.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";
import { SwitcheoToken } from "contracts/zilbridge/token/tokens/SwitcheoTokenETH.sol";
import { ZilBridgeFixture } from "test/zilbridge/DeployZilBridge.t.sol";
import { MockLockProxy } from "./MockLockProxy.sol";


// This deploys a bridge that is ZilBridge token manager on one side and lock-and-release on the other.
// We do this so we can test ZilBridge integration end to end, though in fact the "other side" of the bridge will be provided
// by the code in the Scilla half of this repo.
contract ZilBridgeTokenBridgeIntegrationFixture is
Tester, IRelayerEvents, LockAndReleaseTokenManagerDeployer, LockProxyTokenManagerDeployer, ZilBridgeFixture {
  using MessageHashUtils for bytes;

  ZilBridgeFixture zilBridge;

  // Gateway shared between the two chains
  Vm.Wallet validatorWallet = vm.createWallet(1);
  address validator = validatorWallet.addr;
  address[] validators = [ validator ];
  address sourceUser = vm.addr(2);
  address remoteUser = vm.addr(3);
  uint originalTokenSupply = 1000 ether;
  uint fees = 0.1 ether;

  LockProxyTokenManagerUpgradeableV3 sourceTokenManager;
  // There are "actually" three of these - native (which is lock/release), a mint/burn token and a conventional token.
  // This means we need a remote lock manager and a remote mint burn manager.
  TestToken nativelyOnSource;
  SwitcheoToken nativelyOnRemote;
  ChainGateway sourceChainGateway;
  ValidatorManager sourceValidatorManager;

  // see doc/zilbridge.md
  MockLockProxy mockRemoteLockProxy;
  LockProxyTokenManagerUpgradeableV3 remoteTokenManager;
  SwitcheoToken remoteNativelyOnSource;
  TestToken remoteBridgedGasToken;

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

    // Deploy the token managers
    sourceTokenManager = deployLatestLockProxyTokenManager(address(sourceChainGateway), address(lockProxy), fees);
    mockRemoteLockProxy = new MockLockProxy();
    remoteTokenManager = deployLatestLockProxyTokenManager(address(remoteChainGateway), address(mockRemoteLockProxy), fees);

    vm.stopPrank();
    // Make the token manager an extension.
    installTokenManager(address(sourceTokenManager));

    // That involved a prank, so we need to reset our caller to the validator.
    vm.startPrank(validator);

    // Register contracts to chaingateway
    sourceChainGateway.register(address(sourceTokenManager));
    remoteChainGateway.register(address(remoteTokenManager));

    // Deploy the test tokens.
    nativelyOnSource = new TestToken(originalTokenSupply);
    nativelyOnSource.transfer(sourceUser, originalTokenSupply);
    nativelyOnRemote = new SwitcheoToken(address(lockProxy));

    remoteNativelyOnSource = new SwitcheoToken(address(mockRemoteLockProxy));
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
    vm.stopPrank();
  }

  /* function test_Debug() external { */
  /*   console.log("Hello world!"); */
  /*   setUpZilBridgeForTesting(); */
  /*       vm.startPrank(validator); */
  /*   // Deploy source infra */
  /*   sourceValidatorManager = new ValidatorManager(validator); */
  /*   sourceValidatorManager.initialize(validators); */
  /*   sourceChainGateway = new ChainGateway(address(sourceValidatorManager), validator); */

  /*   // Deploy target infra */
  /*   remoteValidatorManager = new ValidatorManager(validator); */
  /*   remoteValidatorManager.initialize(validators); */
  /*   remoteChainGateway = new ChainGateway(address(remoteValidatorManager), validator); */

  /*   // Deploy the token managers */
  /*   sourceTokenManager = deployLatestLockProxyTokenManager(address(sourceChainGateway), address(lockProxy), fees); */
  /*   remoteMintBurnManager = deployLatestMintAndBurnTokenManager(address(remoteChainGateway), fees); */

  /*   vm.stopPrank(); */
  /*   // Make the token manager an extension. */
  /*   installTokenManager(address(sourceTokenManager)); */

  /*   // That involved a prank, so we need to reset our caller to the validator. */
  /*   vm.startPrank(validator); */

  /*   // Register contracts to chaingateway */
  /*   sourceChainGateway.register(address(sourceTokenManager)); */
  /*   remoteChainGateway.register(address(remoteMintBurnManager)); */

  /*   // Deploy the test tokens. */
  /*   nativelyOnSource = new TestToken(originalTokenSupply); */
  /*   nativelyOnSource.transfer(sourceUser, originalTokenSupply); */
  /*   nativelyOnRemote = new SwitcheoToken(address(lockProxy)); */

  /*   remoteNativelyOnSource = remoteMintBurnManager.deployToken("NativelyOnSource", "NOST", */
  /*                                                                  address(nativelyOnSource), */
  /*                                                                  address(sourceTokenManager), */
  /*                                                                  block.chainid); */
  /*   ITokenManagerStructs.RemoteToken memory remoteNOSStruct = ITokenManagerStructs.RemoteToken({ */
  /*    token: address(remoteNativelyOnSource), */
  /*    tokenManager: address(remoteMintBurnManager), */
  /*    chainId: block.chainid }); */
  /*   sourceTokenManager.registerToken(address(nativelyOnSource), remoteNOSStruct); */
  /*   vm.stopPrank(); */
  /* } */

}

contract ZilBridgeTokenBridgeIntegrationTest is ZilBridgeTokenBridgeIntegrationFixture {
  using MessageHashUtils for bytes;


  function setUp() external {
    installContracts();
  }
  
  function test_happyPath() external {

    startHoax(sourceUser);
    uint amount = originalTokenSupply;
    uint sourceChainId = block.chainid;
    uint remoteChainId = block.chainid;
    assertEq(nativelyOnSource.balanceOf(sourceUser), amount);

    bytes memory data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(sourceChainId, address(sourceTokenManager)), 
        // To
        abi.encode(ITokenManagerStructs.AcceptArgs(address(remoteNativelyOnSource), remoteUser, amount)));

    nativelyOnSource.approve(address(sourceTokenManager), amount);

    // Ask the source token manager to take the source tokens and emit a relayed event
    // (this should transfer the tokens to the lock proxy)
    // TBD: Check this.
    vm.expectEmit(address(sourceChainGateway));
    emit IRelayerEvents.Relayed(remoteChainId,
                                address(remoteTokenManager), data, 1_000_000, 0);
    sourceTokenManager.transfer{value: fees}(
        address(nativelyOnSource), remoteChainId, remoteUser, amount);

    // Now bridge ..
    vm.startPrank(validator);
    bytes[] memory signatures = new bytes[](1);
    signatures[0] = sign(validatorWallet, abi.encode(sourceChainId, remoteChainId,
                                                     address(remoteTokenManager),
                                                     data,
                                                     1_000_000, 0)
                         .toEthSignedMessageHash()
                         );
    remoteChainGateway.dispatch(sourceChainId,
                                address(remoteTokenManager),
                                data,
                                1_000_000,
                                0,
                                signatures);

    // OK. Now ..
    assertEq(remoteNativelyOnSource.balanceOf(remoteUser), amount);
    assertEq(remoteNativelyOnSource.totalSupply(), amount);
    assertEq(nativelyOnSource.totalSupply(), amount);
    assertEq(nativelyOnSource.balanceOf(sourceUser), 0);

    // Send it back again.
    startHoax(remoteUser);
    remoteNativelyOnSource.approve(address(remoteTokenManager), amount);
    remoteTokenManager.transfer{value: fees}(
        address(nativelyOnSource), sourceChainId, sourceUser, amount);

    vm.startPrank(validator);
    data = abi.encodeWithSelector(
        TokenManagerUpgradeable.accept.selector,
        // From
        CallMetadata(remoteChainId, address(remoteTokenManager)),
        // To
        abi.encode(
            ITokenManagerStructs.AcceptArgs(address(nativelyOnSource), sourceUser, amount)
                   ));
    signatures[0] = sign(
        validatorWallet,
        abi.encode(remoteChainId, sourceChainId,
                   address(sourceTokenManager),
                   data,
                   1_000_000,
                   0).toEthSignedMessageHash());
    sourceChainGateway.dispatch(remoteChainId,
                                address(sourceTokenManager),
                                data,
                                1_000_000,
                                0,
                                signatures);
    // Check balances are back ..
    assertEq(remoteNativelyOnSource.balanceOf(remoteUser), 0);
    assertEq(nativelyOnSource.balanceOf(sourceUser), amount);
  }
}
