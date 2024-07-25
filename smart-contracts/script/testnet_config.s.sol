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
  address public constant zq_lockAndReleaseOrNativeTokenManager = 0x86c4405C2e3914490BC043A19dA5373D6d187aa7;

  // BSC zilbridge tokens.
  address public constant bsc_erc20 =  0xa1a47FA4D26137329BB08aC2E5F9a6C32D180fE3;
  address public constant bsc_bridgedzrc2 = 0x201eDd0521cF4B577399F789e22E05405D500163;
  address public constant bsc_bridgedzil = 0xfA3cF3BBa7f0fA1E8FECeE532512434A7d275d41;

  // Scilla contracts.
  address public constant zq_bridged_erc20 = address(0x00c8704B0196FE5a15E33B2a328Dae1d4275Bb5A6F);
  address public constant zq_bridged_bnb = address(0x0067e5375cd3B2738A591050589452B8189dc470eF);
  address public constant zq_zrc2 = address(0x00d5eD1175af29C49237BB82663Ea2e7Fa2eaa9EDb);

  // ERC20 fascias for Scilla contracts
  address public constant zq_bridged_erc20_evm = address(0x8CB156B19947283F9700e5891ed6d013454b0570);
  address public constant zq_bridged_bnb_evm = address(0xe99aCb73ca54766013A253d040021f392302159E);
  address public constant zq_zrc2_evm = address(0x2A82a13A118c0f9E203a9C006742024354D0f4Ca);
}
