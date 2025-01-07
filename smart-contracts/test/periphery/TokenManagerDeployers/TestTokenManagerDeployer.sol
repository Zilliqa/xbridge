// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity 0.8.20;

import {ERC1967Proxy} from "@openzeppelin/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {TokenManagerUpgradeableV4, ITokenManagerV4Events} from "contracts/periphery/TokenManagerV4/TokenManagerUpgradeableV4.sol";
import {ITokenManager, ITokenManagerFees, ITokenManagerStructs, ITokenManagerEvents} from "contracts/periphery/TokenManagerV2/TokenManagerUpgradeableV2.sol";
import {ITokenManagerFeesEvents} from "contracts/periphery/TokenManagerV2/TokenManagerFees.sol";
import {IRelayer} from "contracts/core/Relayer.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {TestToken} from "test/Helpers.sol";
import {LockAndReleaseTokenManagerDeployer} from "test/periphery/TokenManagerDeployers/LockAndReleaseTokenManagerDeployer.sol";

contract TestTokenManagerUpgradeableV4 is TokenManagerUpgradeableV4 {
  event TransferEvent(address indexed token, address indexed from, uint indexed amount);
  event AcceptEvent(address indexed token, address indexed from, uint indexed amount);

  constructor() {
    _disableInitializers();
  }

  function initialize(uint fees) external initializer {
    __TokenManager_init(address(0));
    _setFees(fees);
  }

  function _handleTransfer(address token, address from, uint amount) internal override {
    emit TransferEvent(token, from, amount);
  }

  function _handleAccept(address token, address recipient, uint amount) internal override {
    emit AcceptEvent(token, recipient, amount);
  }

}

abstract contract TestTokenManagerDeployer {
  function deployTestTokenManagerV4(uint fees) public returns (TestTokenManagerUpgradeableV4) {
    address implementation = address(new TestTokenManagerUpgradeableV4());
    address proxy = address(new ERC1967Proxy(implementation,
                                             abi.encodeCall(
                                                 TestTokenManagerUpgradeableV4.initialize,
                                                            fees)));
    return TestTokenManagerUpgradeableV4(proxy);
  }

}
