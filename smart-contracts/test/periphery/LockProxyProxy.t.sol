// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {Tester, Vm} from "test/Tester.sol";
import { LockProxyProxy } from "contracts/periphery/LockProxyProxy.sol";
import { ILockProxyExtensionTransfer } from "contracts/periphery/ILockProxyExtensionTransfer.sol";
import { TestToken } from "test/Helpers.sol";

contract TestLockProxyProxy is Tester, ILockProxyExtensionTransfer {
  Vm.Wallet validatorWallet = vm.createWallet("validator");
  address validator = validatorWallet.addr;

  Vm.Wallet callerWallet = vm.createWallet("caller");
  Vm.Wallet otherWallet = vm.createWallet("other");

  Vm.Wallet transferorWallet = vm.createWallet("transferor");

  LockProxyProxy theProxy;
  TestToken allowedToken;
  TestToken disallowedToken;
  uint tokenSupply = 1000 ether;
  uint tokensTransferred = 12 ether;

  function extensionTransfer(address _receivingAddress, address /* _assetHash */, uint256 _amount) external returns (bool) {
    assertEq(_receivingAddress, transferorWallet.addr);
    // Deliberately don't validate on the asset hash because we want the caller to do it.
    assertEq(_amount, tokensTransferred);
    return true;
  }


  function setUp() public {
    vm.startPrank(validator);
    // Deploy the test token
    allowedToken = new TestToken(tokenSupply);
    disallowedToken = new TestToken(tokenSupply);
    address[] memory allowedTokens = new address[](1);
    allowedTokens[0] = address(allowedToken);
    theProxy = new LockProxyProxy(allowedTokens, validator, address(this));
    theProxy.addCaller(callerWallet.addr);
    vm.stopPrank();
  }

  function testTransfer() public {
    vm.startPrank(callerWallet.addr);
    ILockProxyExtensionTransfer(theProxy).extensionTransfer(transferorWallet.addr, address(allowedToken),
                                                            tokensTransferred );
    vm.stopPrank();
  }

  function testInvalidToken() public {
    vm.expectRevert("Bad asset hash");
    vm.startPrank(callerWallet.addr);
    ILockProxyExtensionTransfer(theProxy).extensionTransfer(transferorWallet.addr, address(disallowedToken), tokensTransferred);
    vm.stopPrank();
  }

  function testInvalidCaller() public {
    vm.expectRevert();
    vm.startPrank(otherWallet.addr);
    ILockProxyExtensionTransfer(theProxy).extensionTransfer(transferorWallet.addr, address(allowedToken), tokensTransferred);
    vm.stopPrank();
  }

  function testRemoveCaller() public {
    vm.startPrank(validator);
    theProxy.removeCaller(callerWallet.addr);
    vm.stopPrank();
    vm.startPrank(callerWallet.addr);
    vm.expectRevert();
    ILockProxyExtensionTransfer(theProxy).extensionTransfer(transferorWallet.addr, address(allowedToken),
                                                            tokensTransferred );
    vm.stopPrank();
    vm.startPrank(validator);
    theProxy.addCaller(callerWallet.addr);
    vm.stopPrank();
    vm.startPrank(callerWallet.addr);
    ILockProxyExtensionTransfer(theProxy).extensionTransfer(transferorWallet.addr, address(allowedToken),
                                                            tokensTransferred );
    vm.stopPrank();
  }
}
