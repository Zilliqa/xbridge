pragma solidity ^0.8.20;

/// Inherit from this contract to get constants that tells you where other testnet contracts are.
abstract contract TestnetConfig {
  address public constant bsc_EthCrossChainData = 0xd77a160f954AbF8154f80EA53378ACa55bcAD548;
  // Can't be verified.
  address public constant bsc_ccm = 0x0EDb0830a5a28E60Bc28BCce3f4e1EC23b5E5783;
  address public constant bsc_ccmProxy = 0xE19738378c75cf2b3D704472bE81d7e036F4Ee04;
  address public constant bsc_lockProxy = 0x5B51e17837fc8F01b3C3ef29E882981e9414C159;
  // Can't be verified.
  address public constant bsc_extendCCM = 0x32ffa2C4c670A0fd0e94CF6457ac2FA7Ef007d55;
  address public constant bsc_zilBridgeTokenManager = 0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7;

  address public constant bsc_erc20 = 0x59A23d0957B63BC6c5682F211eE731513EECBB98;
  address public constant bsc_bridgedzrc2 = 0x0d27244Ec509e7cbBde6d5c82DdD0e9F34873bF2;
  address public constant bsc_bridgedzil = 0x33aC4ae9c514213a51D529114523Dd168c1d3b73;

  /// Deployed by XBridge testnet deployment
  address public constant bsc_chainGateway = 0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE;
  address public constant zq_chainGateway = 0x7370e69565BB2313C4dA12F9062C282513919230;
  address public constant zq_lockAndReleaseOrNativeTokenManager = 0xBe90AB2cd65E207F097bEF733F8D239A59698b8A;

  // Scilla contracts.
  address public constant zq_bridged_erc20 = address(0x00839901f1e39De75301667C6bBbF7fB556Ea2510E);
  address public constant zq_bridged_bnb = address(0x0006852e68A3c24917cfA4C2dbDaE4B308C69aDA5e);
  address public constant zq_zrc2 = address(0x00155F0f76b660290F2F00Bb5674b80eDC208bF2e6);

  // ERC20 fascias for Scilla contracts
  address public constant zq_bridged_erc20_evm = address(0xD74298C0f4D24D6143CF20FA31E44Aea85a72C98);
  address public constant zq_bridged_bnb_evm = address(0x044B7F27c0d9aBDE9C69ba0CBd57ab3Ccdc2cab4);
  address public constant zq_zrc2_evm = address(0xcC82E101eAe30BdE53794d7Fe20B43E325011789);

}
