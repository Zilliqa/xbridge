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
  address public constant bsc_zilBridgeTokenManager =  0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7;


  /// Deployed by XBridge testnet deployment
  address public constant bsc_chainGateway = 0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE;
  address public constant zq_chainGateway = 0x7370e69565BB2313C4dA12F9062C282513919230;
  address public constant zq_lockAndReleaseTokenManager =  0x1509988c41f02014aA59d455c6a0D67b5b50f129;
  address public constant zq_lockAndReleaseOrNativeTokenManager = 0x5e502559ab6e99949b0eE72d4ebCe05f31E026dC;

  // BSC zilbridge tokens.
  address public constant bsc_erc20 =  0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3;
  address public constant bsc_bridgedzrc2 = 0x201eDd0521cF4B577399F789e22E05405D500163;
  address public constant bsc_bridgedzil = 0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41;

  // Scilla contracts.
  address public constant zq_bridged_erc20 = address(0x00f281D459E5FdA75f12eEca2D33E3aa03f6456994);
  address public constant zq_bridged_bnb = address(0x00976050703b8067ab25a56A22e24e404222B07a33);
  address public constant zq_zrc2 = address(0x00f1c2F2dadC13d03939c52d7A763dAF188f431AD6);

  // ERC20 fascias for Scilla contracts
  address public constant zq_bridged_erc20_evm = address(0x2aDFdb71103b8587F609b262b3E7E6161D3f6B1f);
  address public constant zq_bridged_bnb_evm = address(0x9707F1C6A02c5D8682669d309c046c5Af6c3130e);
  address public constant zq_zrc2_evm = address(0xCf795CF70C29588fb6885CB8982EAE04354e1BB4);
}
