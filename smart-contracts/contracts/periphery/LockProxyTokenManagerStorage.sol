// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

interface ILockProxyTokenManagerStorage {
  event LockProxyStorageUpdated(address oldLockProxy, address newLockProxy, address oldLockProxyProxy, address newLockProxyProxy);
  function getLockProxy() external view returns (address);
  function getLockProxyProxy() external view returns (address);
  function setLockProxyData(address lockProxy, address lockProxyProxy) external;
}

abstract contract LockProxyTokenManagerStorage is ILockProxyTokenManagerStorage {
  /// @custom:storage-location erc7201:zilliqa.storage.LockProxyTokenManagerStorage
  struct LockProxyTokenManagerStorageStruct {
    address lockProxyProxy;
    address lockProxy;
  }

  // keccack256(abi.encode(uint256(keccack256("zilliqa.storage.LockProxyTokenManagerStorage"))-1)) & ~bytes32(uint256(0xff))
  bytes32 private constant Lock_Proxy_Storage_Location = 0xb22af1dfa3d79e3af56bf3b03e8c9cb6d48fc6bbb7ec48dcbfc0dbccf342f800;

  function _getLockProxyTokenManagerStorageStruct() private pure returns (LockProxyTokenManagerStorageStruct storage $)
  {
    assembly {
   $.slot := Lock_Proxy_Storage_Location
    }
  }

  function getLockProxyProxy() public view returns (address) {
    LockProxyTokenManagerStorageStruct storage $ = _getLockProxyTokenManagerStorageStruct();
    return $.lockProxyProxy;
  }

  function getLockProxy() public view returns (address) {
    LockProxyTokenManagerStorageStruct storage $ = _getLockProxyTokenManagerStorageStruct();
    return $.lockProxy;
  }

  function _setLockProxyData(address lockProxy, address lockProxyProxy) internal {
    LockProxyTokenManagerStorageStruct storage $ = _getLockProxyTokenManagerStorageStruct();
    emit LockProxyStorageUpdated($.lockProxy, lockProxy, $.lockProxyProxy, lockProxyProxy);
    $.lockProxy = lockProxy;
    $.lockProxyProxy = lockProxyProxy;
  }

}
