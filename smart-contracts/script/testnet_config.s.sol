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


  /// Deployed by XBridge testnet deployment
  address public constant bsc_chainGateway = 0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE;
}
