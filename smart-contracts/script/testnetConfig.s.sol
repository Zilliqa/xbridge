pragma solidity ^0.8.20;

/*** @dev Inherit from this contract to get constants that tells you where other testnet contracts are.
 * I did consider structuring this a bit more closely, but there is sufficient diversity between
 * chains that I haven't,  yet.
 */
abstract contract TestnetConfig {
  address public constant primaryValidatorAddress = 0xb494D016F2CF329224e2dB445aA748Cf96C18C29;
 
  // bsc testnet
  address public constant bscEthCrossChainDataAddress = 0xd77a160f954AbF8154f80EA53378ACa55bcAD548;

  uint public constant bscChainId = 97;
  // Can't be verified.
  address public constant bscCCMAddress = 0x0EDb0830a5a28E60Bc28BCce3f4e1EC23b5E5783;
  address public constant bscCCMProxyAddress = 0xE19738378c75cf2b3D704472bE81d7e036F4Ee04;
  address public constant bscLockProxyAddress = 0x5B51e17837fc8F01b3C3ef29E882981e9414C159;
  address public constant bscLockProxyProxyAddress = 0xCbE7630872D225a5BA6A32B59CaB8da3713806b0;

  address public constant bscNewMintAndBurnTokenManagerAddress = 0xA6D73210AF20a59832F264fbD991D2abf28401d0;
  // Can't be verified.
  address public constant bscExtendCCMAddress = 0x32ffa2C4c670A0fd0e94CF6457ac2FA7Ef007d55;
  address public constant bscLockProxyTokenManagerAddress =  0x36b8A9cd6Bf9bfA5984093005cf81CAfB1Bf06F7;
  // BSC zilbridge tokens.
  address public constant bscERC20Address =  0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3;
  address public constant bscBridgedZRC2Address = 0x201eDd0521cF4B577399F789e22E05405D500163;
  address public constant bscBridgedZILAddress = 0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41;

  /// Deployed by the original XBridge testnet deployment (prior to zilBridge)
  address public constant bscChainGatewayAddress = 0xa9A14C90e53EdCD89dFd201A3bF94D867f8098fE;
  address public constant bscMintAndBurnTokenManagerAddressOld = 0xd10077bCE4A9D19068965dE519CED8a2fC1B096C;
  address public constant bscTestTokenAddress = 0x6d78c86D66DfE5Be5F55FBAA8B1d3FD28edfF396;

  /// Zilliqa testnet

  uint public constant zqChainId = 33101;
  address public constant zqChainGatewayAddress = 0x7370e69565BB2313C4dA12F9062C282513919230;
  address public constant zqLockAndReleaseTokenManagerAddress =  0x1509988c41f02014aA59d455c6a0D67b5b50f129;
  address public constant zqLockAndReleaseOrNativeTokenManagerAddress = 0x41823941D00f47Ea1a98D75586915BF828F4a038;

  // Scilla contracts.
  address public constant zqBridgedERC20Address = address(0x009892a6E972B46Bca767ed552Fb06E25A35a49ebF);
  address public constant zqBridgedBNBAddress = address(0x008fe819662a7Db7e03943877BA771E7A0902Ef96d);
  address public constant zqZRC2Address = address(0x005dD38E64DA8F7d541d8af45fE00Bf37F6A2C6195);

  // ERC20 fascias for Scilla contracts
  address public constant zqBridgedERC20EVMAddress = 0x9Be4DCfB335A263c65a8A763d55710718bbdb416;
  address public constant zqBridgedBNBEVMAddress = 0x40647A0C0024755Ef48Bc7C26a979ED833Eb6a15;
  address public constant zqZRC2EVMAddress = 0xd3750B930ED52C26584C18B4f5eeAb986D7f3b36;

  // Deployed back in the depths of time; recorded here so we can use them in scripts
  address public constant zqLegacyTestTokenAddress = 0x63B6ebD476C84bFDd5DcaCB3f974794FC6C2e721;

  /// ZilBridge constants that we use whilst testing the zilbridge/xbridge integration
  uint64 public constant zbZilliqaChainId = 18;
  uint64 public constant zbBscChainId = 6;


  // Sepolia
  address public constant ethLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60;

  // Polygon
  address public constant polLockProxyProxy = 0xD819257C964A78A493DF93D5643E9490b54C5af2;


  // Scaled token test
  address public constant zqScaledTokenERC20Address = 0xd6B5231DC7A5c37461A21A8eB42610e09113aD1a;
  address public constant bscBridgedScaledTokenAddress = 0xBA97f1F72b217BdC5684Ec175bE5615C0E50aBda;

  // Base sepolia
  uint public constant baseChainId = 84532;
  address public constant baseChainGatewayAddress = 0xaa084F6EE63B6f5F4c9F84cDbEC3C690DA00d56D;
  address public constant baseValidatorManagerAddress =  0xC2A3A607a5E48fF65900a466B16F8F69402ed467;
  address public constant baseLockAndReleaseOrNativeTokenManagerUpgradeable = 0x3Be6E686397f04901Be15e3e02EDC0c7565e4b13;
  address public constant baseMintAndBurnTokenManagerUpgradeable = 0x236D120c50b9498422842E6D7DF0A9D6040507aa;
  address public constant basezbTestTokenAddress = 0x9DFe189ed442cCfB6c929d1b1a25e4c13354C27e;

}
