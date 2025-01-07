// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {IRelayer, CallMetadata} from "contracts/core/Relayer.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Ownable2StepUpgradeable} from "@openzeppelin/contracts-upgradeable/access/Ownable2StepUpgradeable.sol";
import {ITokenManagerEvents, ITokenManagerStructs} from "contracts/periphery/TokenManagerUpgradeable.sol";
import {TokenManagerFees, ITokenManagerFees} from "contracts/periphery/TokenManagerV2/TokenManagerFees.sol";
import {PausableUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/PausableUpgradeable.sol";

interface ITokenManagerV4Structs {
  struct ScaledRemoteToken {
    address token;
    address tokenManager;
    uint chainId;
    int8 scale;
  }
}

interface ITokenManagerV4Events {
  event TokenScaleChanged (
      address indexed token,
      uint remoteChainId,
      int8 remoteScale
                           );
}

interface ITokenManager is
    ITokenManagerEvents,
    ITokenManagerStructs,
    ITokenManagerFees,
  ITokenManagerV4Structs,
  ITokenManagerV4Events
{
    error InvalidSourceChainId();
    error InvalidTokenManager();
    error NotGateway();
    error InvalidTokenRouting();
    // the amount of local tokens we tried to send, the nearest scaled amount we could recieve on the target chain, and
    // the amount of local tokens that would correspond to.
    error InvalidTokenAmount(uint256 sent, uint256 adjusted, uint256 reconstructed);

    function getGateway() external view returns (address);

    function setGateway(address _gateway) external;

    function getRemoteTokens(
        address token,
        uint remoteChainId
    ) external view returns (RemoteToken memory);

    function registerToken(
        address token,
        RemoteToken memory remoteToken
    ) external;

    function setFees(uint newFees) external;

    function withdrawFees(address payable to) external;

    function pause() external;

    function unpause() external;

    function transfer(
        address token,
        uint remoteChainId,
        address remoteRecipient,
        uint amount
    ) external payable; // Update to payable

    function accept(
        CallMetadata calldata metadata,
        bytes calldata args
    ) external;
}

abstract contract TokenManagerUpgradeableV4 is
    ITokenManager,
    Initializable,
    UUPSUpgradeable,
    Ownable2StepUpgradeable, // V3 changed to Ownable2StepUpgradeable
    TokenManagerFees,
    PausableUpgradeable
{
    /// @custom:storage-location erc7201:zilliqa.storage.TokenManager
    struct TokenManagerStorage {
        address gateway;
        // localTokenAddress => remoteChainId => RemoteToken
        mapping(address => mapping(uint => RemoteToken)) remoteTokens;
        // This stores the scale for remote tokens, as remote_token.decimals-local_token.decimals.
        // So, when sending a token with a +ve scale, we shift left.
        // When sending a token with a -ve scale, we shift right.
        // When receiving a token, we do nothing.
        // This allows us to validate that the tokens can be exactly converted to the remote
        // and revert the sending txn if not.
        mapping(address => mapping(uint => int8)) scaleForRemoteTokens;
    }

    // keccak256(abi.encode(uint256(keccak256("zilliqa.storage.TokenManager")) - 1)) & ~bytes32(uint256(0xff))
    bytes32 private constant Token_Manager_Storage_Location =
        0x4a6c2e6a7e6518c249bdcd1d934ea16ea5325bbae105af814eb678f5f49f3400;

    function _getTokenManagerStorage()
        private
        pure
        returns (TokenManagerStorage storage $)
    {
        assembly {
            $.slot := Token_Manager_Storage_Location
        }
    }


    function getGateway() public view returns (address) {
        TokenManagerStorage storage $ = _getTokenManagerStorage();
        return $.gateway;
    }

    function getRemoteTokens(
        address token,
        uint remoteChainId
    ) public view returns (RemoteToken memory) {
        TokenManagerStorage storage $ = _getTokenManagerStorage();
        return $.remoteTokens[token][remoteChainId];
    }

    function getRemoteTokenScale(address token, uint remoteChainId) public view returns (int8) {
      TokenManagerStorage storage $ = _getTokenManagerStorage();
      return $.scaleForRemoteTokens[token][remoteChainId];
    }

    modifier onlyGateway() {
        if (_msgSender() != address(getGateway())) {
            revert NotGateway();
        }
        _;
    }

    function __TokenManager_init(address _gateway) internal onlyInitializing {
        __Ownable_init(_msgSender());
        _setGateway(_gateway);
    }

    function _authorizeUpgrade(address) internal virtual override onlyOwner {}

    function _setGateway(address _gateway) internal {
        TokenManagerStorage storage $ = _getTokenManagerStorage();
        $.gateway = _gateway;
    }

    function setGateway(address _gateway) external onlyOwner {
        _setGateway(_gateway);
    }

    function _removeToken(address localToken, uint remoteChainId) internal {
        TokenManagerStorage storage $ = _getTokenManagerStorage();
        delete $.remoteTokens[localToken][remoteChainId];
        delete $.scaleForRemoteTokens[localToken][remoteChainId];
        emit TokenRemoved(localToken, remoteChainId);
    }

    function _registerToken(
        address localToken,
        RemoteToken memory remoteToken
    ) internal {
        TokenManagerStorage storage $ = _getTokenManagerStorage();
        $.remoteTokens[localToken][remoteToken.chainId] = remoteToken;
        emit TokenRegistered(
            localToken,
            remoteToken.token,
            remoteToken.tokenManager,
            remoteToken.chainId
        );
    }

    function _setScaleForToken(address localToken,
                               uint remoteChainId,
                               int8 scale) internal {
      TokenManagerStorage storage $ = _getTokenManagerStorage();
      $.scaleForRemoteTokens[localToken][remoteChainId] = scale;
      emit TokenScaleChanged( localToken,
                              remoteChainId,
                              scale );
    }


    function _getScaleForToken(address localToken,
                               uint remoteChainId) internal view returns (int8) {
      TokenManagerStorage storage $ = _getTokenManagerStorage();
      return $.scaleForRemoteTokens[localToken][remoteChainId];
    }

    function _scaleAmount(uint amount,
                          address localToken,
                          uint remoteChainId) internal returns (uint)
    {
      int8 scale = _getScaleForToken(localToken, remoteChainId);
      uint adjusted;
      uint reconstructed;

      if (scale < 0) {
        // Must be < 0 since the condition above requires it.
        uint divisor = uint(10)**uint(int256(-scale));
        adjusted = (amount / divisor);
        reconstructed = amount * divisor;
      } else if (scale > 0) {
        // Must be > 0 since the condition above requires it.
        uint multiplier = uint(10)**uint(int256(scale));
        adjusted = amount * multiplier;
        reconstructed = amount / multiplier;
      }
      // If scale == 0, nothing is done, which is what is intended.
      if (adjusted != reconstructed) {
        revert InvalidTokenAmount(amount, adjusted, reconstructed);
      }
      return adjusted;
    }
    
    // Token Overrides
    function registerToken(
        address token,
        RemoteToken memory remoteToken
    ) external virtual onlyOwner {
        _registerToken(token, remoteToken);
    }

    // V2 New Function
    function setFees(
        uint newFees
    ) external override(ITokenManager, TokenManagerFees) onlyOwner {
        _setFees(newFees);
    }

    // V2 New Function
    function withdrawFees(
        address payable to
    ) external override(ITokenManager, TokenManagerFees) onlyOwner {
        _withdrawFees(to);
    }

    // V2 New Function
    function pause() external onlyOwner {
        _pause();
    }

    // V2 New Function
    function unpause() external onlyOwner {
        _unpause();
    }

    // V4 new function
    function setScaleForToken(address localToken,
                              uint remoteChainId,
                              int8 scale) external virtual onlyOwner {
      _setScaleForToken(localToken, remoteChainId, scale);
    }

    // TO OVERRIDE – Incoming
    function _handleTransfer(
        address token,
        address from,
        uint amount
    ) internal virtual;

    // TO OVERRIDE – Outgoing
    function _handleAccept(
        address token,
        address recipient,
        uint amount
    ) internal virtual;

    // V2 Modified: `whenNotPaused` & `checkFees` modifiers, also made payable
    function transfer(
        address token,
        uint remoteChainId,
        address remoteRecipient,
        uint amount
    ) external payable virtual whenNotPaused checkFees {
        RemoteToken memory remoteToken = getRemoteTokens(token, remoteChainId);
        if (remoteToken.tokenManager == address(0)) {
            revert InvalidTokenRouting();
        }

        // If this does not exactly correspond with amount, _scaleAmount() will revert.
        uint scaledAmount = _scaleAmount(amount, token, remoteChainId);

        // We take the original amount.
        _handleTransfer(token, _msgSender(), amount);

        // .. and send the scaled amount.
        IRelayer(getGateway()).relayWithMetadata(
            remoteToken.chainId,
            remoteToken.tokenManager,
            this.accept.selector,
            abi.encode(AcceptArgs(remoteToken.token, remoteRecipient, scaledAmount)),
            1_000_000
        );
    }

    // Incoming
    // No pausing here because we want incoming txns to go through that have already initiated
    // We cannot scale anything here, because there's no way to stop the tokens having been sent.
    function accept(
        CallMetadata calldata metadata,
        bytes calldata _args
    ) external virtual onlyGateway {
        AcceptArgs memory args = abi.decode(_args, (AcceptArgs));

        RemoteToken memory remoteToken = getRemoteTokens(
            args.token,
            metadata.sourceChainId
        );
        // We use tokenManager != 0 as a proxy for the existence of
        // this mapping entry.
        if (remoteToken.tokenManager == address(0)) {
            revert InvalidTokenRouting();
        }
        if (metadata.sourceChainId != remoteToken.chainId) {
            revert InvalidSourceChainId();
        }
        if (metadata.sender != remoteToken.tokenManager) {
            revert InvalidTokenManager();
        }

        _handleAccept(args.token, args.recipient, args.amount);
    }
}
