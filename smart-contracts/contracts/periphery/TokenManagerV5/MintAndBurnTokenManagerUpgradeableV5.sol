// SPDX-License-Identifier: MIT OR Apache-2.0
pragma solidity ^0.8.20;

import {TokenManagerUpgradeableV4, ITokenManager} from "contracts/periphery/TokenManagerV4/TokenManagerUpgradeableV4.sol";
import {BridgedTokenV2} from "contracts/periphery/BridgedTokenV2.sol";

interface IMintAndBurnTokenManager {
    event Minted(address indexed token, address indexed recipient, uint amount);
    event Burned(address indexed token, address indexed from, uint amount);
    event BridgedTokenDeployed(
        address token,
        address remoteToken,
        address remoteTokenManager,
        uint remoteChainId
    );
}

contract MintAndBurnTokenManagerUpgradeableV5 is
    IMintAndBurnTokenManager,
    TokenManagerUpgradeableV4
{
    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function deployToken(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        address remoteToken,
        address tokenManager,
        uint remoteChainId
    ) external returns (BridgedTokenV2) {
        return
            _deployToken(
                name,
                symbol,
                decimals,
                remoteToken,
                tokenManager,
                remoteChainId
            );
    }

    function deployToken(
        string calldata name,
        string calldata symbol,
        address remoteToken,
        address tokenManager,
        uint remoteChainId
    ) external returns (BridgedTokenV2) {
        return
            _deployToken(
                name,
                symbol,
                18,
                remoteToken,
                tokenManager,
                remoteChainId
            );
    }

    function _deployToken(
        string calldata name,
        string calldata symbol,
        uint8 decimals,
        address remoteToken,
        address tokenManager,
        uint remoteChainId
    ) internal onlyOwner returns (BridgedTokenV2) {
        // TODO: deployed counterfactually
        BridgedTokenV2 bridgedToken = new BridgedTokenV2(name, symbol, decimals);
        RemoteToken memory remoteTokenStruct = RemoteToken(
            remoteToken,
            tokenManager,
            remoteChainId
        );

        _registerToken(address(bridgedToken), remoteTokenStruct);

        emit BridgedTokenDeployed(
            address(bridgedToken),
            remoteToken,
            tokenManager,
            remoteChainId
        );

        return bridgedToken;
    }

    function transferTokenOwnership(
        address localToken,
        uint remoteChainId,
        address newOwner
    ) external onlyOwner {
        BridgedTokenV2(localToken).transferOwnership(newOwner);
        _removeToken(localToken, remoteChainId);
    }

    // Outgoing
    function _handleTransfer(
        address token,
        address from,
        uint amount
    ) internal override {
        BridgedTokenV2(token).burnFrom(from, amount);
        emit Burned(token, from, amount);
    }

    // Incoming
    function _handleAccept(
        address token,
        address recipient,
        uint amount
    ) internal override {
        BridgedTokenV2(token).mint(recipient, amount);
        emit Minted(token, recipient, amount);
    }
}
