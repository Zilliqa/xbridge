pragma solidity ^0.8.20;

/*** @dev Inherit from this contract to get constants that tells you where other testnet contracts are.
 * I did consider structuring this a bit more closely, but there is sufficient diversity between
 * chains that I haven't,  yet.
 */
abstract contract TestnetConfig {
  // bsc testnet
  address public constant bscEthCrossChainDataAddress = 0xd77a160f954AbF8154f80EA53378ACa55bcAD548;

  uint public constant bscChainId = 97;
  // Can't be verified.
  address public constant bscCCMAddress = 0x0EDb0830a5a28E60Bc28BCce3f4e1EC23b5E5783;
  address public constant bscCCMProxyAddress = 0xE19738378c75cf2b3D704472bE81d7e036F4Ee04;
  address public constant bscLockProxyAddress = 0x5B51e17837fc8F01b3C3ef29E882981e9414C159;
  // Can't be verified.
  address public constant bscExtendCCMAddress = 0x32ffa2C4c670A0fd0e94CF6457ac2FA7Ef007d55;
  address public constant bscLockProxyTokenManagerAddress =  0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7;
  // BSC zilbridge tokens.
  address public constant bscERC20Address =  0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3;
  address public constant bscBridgedZRC2Address = 0x201eDd0521cF4B577399F789e22E05405D500163;
  address public constant bscBridgedZILAddress = 0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41;

  /// Deployed by the original XBridge testnet deployment (prior to zilBridge)
  address public constant bscChainGatewayAddress = 0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE;
  address public constant bscMintAndBurnTokenManagerAddress = 0xd10077bCE4A9D19068965dE519CED8a2fC1B096C;
  address public constant bscTestTokenAddress = 0x6d78c86D66DfE5Be5F55FBAA8B1d3FD28edfF396;

  /// Zilliqa testnet

  uint public constant zqChainId = 33101;
  address public constant zqChainGatewayAddress = 0x7370e69565BB2313C4dA12F9062C282513919230;
  address public constant zqLockAndReleaseTokenManagerAddress =  0x1509988c41f02014aA59d455c6a0D67b5b50f129;
  address public constant zqLockAndReleaseOrNativeTokenManagerAddress = 0x5e502559ab6e99949b0eE72d4ebCe05f31E026dC;

  // Scilla contracts.
  address public constant zqBridgedERC20Address = address(0x00f281D459E5FdA75f12eEca2D33E3aa03f6456994);
  address public constant zqBridgedBNBAddress = address(0x00976050703b8067ab25a56A22e24e404222B07a33);
  address public constant zqZRC2Address = address(0x00f1c2F2dadC13d03939c52d7A763dAF188f431AD6);

  // ERC20 fascias for Scilla contracts
  address public constant zqBridgedERC20EVMAddress = address(0x2aDFdb71103b8587F609b262b3E7E6161D3f6B1f);
  address public constant zqBridgedBNBEVMAddress = address(0x9707F1C6A02c5D8682669d309c046c5Af6c3130e);
  address public constant zqZRC2EVMAddress = address(0xCf795CF70C29588fb6885CB8982EAE04354e1BB4);

  // Deployed back in the depths of time; recorded here so we can use them in scripts
  address public constant zqLegacyTestTokenAddress = 0x63B6ebD476C84bFDd5DcaCB3f974794FC6C2e721;

  /// ZilBridge constants that we use whilst testing the zilbridge/xbridge integration
  uint64 public constant zbZilliqaChainId = 18;
  uint64 public constant zbBscChainId = 6;
}
