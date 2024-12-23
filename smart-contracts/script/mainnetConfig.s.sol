pragma solidity ^0.8.20;

/*** @dev Inherit from this contract to get constants that tells you where other testnet contracts are.
 * I did consider structuring this a bit more closely, but there is sufficient diversity between
 * chains that I haven't,  yet.
 */
abstract contract MainnetConfig {
  uint public constant zilChainId = 32769;
  uint public constant bscChainId = 56;
  uint public constant polChainId = 137;
  uint public constant arbChainId = 42161;
  uint public constant ethChainId = 1;

  address public constant zilLockProxy = 0xd73C6b871b4D0E130d64581993B745FC938A5be7;
  // This exists, but is useless, because you can't set extensions on Scilla lockProxy.
  // address public constant zilUnrestrictedLockProxyProxy = 0x7519550ae8b6f9d32E9c1A939Fb5C186f660BE5b;
  address public constant zilChainGatewayAddress = 0xbA44BC29371E19117DA666B729A1c6e1b35DDb40;
  address public constant zilLockAndReleaseTokenManagerDoNotUseForZilbridge = 0x6D61eFb60C17979816E4cE12CD5D29054E755948;

  address public constant zilLockAndReleaseOrNativeTokenManagerUpgradeable = 0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C;
  address public constant zilLockProxyTokenManager = 0xb4132E757345f0EfD91af38cD824Be441F34fe25;
  address public constant zilLockAndReleaseOrNativeTokenManagerProxyTarget = 0x99bCB148BEC418Fc66ebF7ACA3668ec1C6289695;
  address public constant zilLockProxyTokenManagerProxyTarget = 0x8A86888C2DDF741A7a12E5e329C0842F1A9E9797;

  address public constant bscLockProxy = 0xb5D4f343412dC8efb6ff599d790074D0f1e8D430;
  address public constant bscLockProxyProxy = 0xD819257C964A78A493DF93D5643E9490b54C5af2;
  address public constant bscChainGatewayAddress = 0x3967f1a272Ed007e6B6471b942d655C802b42009;
  address public constant bscTokenManagerMintAndBurn = 0xF391A1Ee7b3ccad9a9451D2B7460Ac646F899f23;
  address public constant bscLockAndReleaseOrNativeTokenManagerUpgradeable = 0x1202078D298Ff0358A95b6fbf48Ec166dB414660;
  address public constant bscLockProxyTokenManager = 0x2EE8e8D7C113Bb7c180f4755f06ed50bE53BEDe5;

  address public constant polLockProxy = 0x43138036d1283413035B8eca403559737E8f7980;
  address public constant polLockProxyProxy = 0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b;
  address public constant polChainGatewayAddress = 0x796d796F28b3dB5287e560dDf75BC9B00F0CD609;
  address public constant polLockAndReleaseOrNativeTokenManagerUpgradeable = 0x7519550ae8b6f9d32E9c1A939Fb5C186f660BE5b;
  address public constant polLockProxyTokenManager = 0x3faC7cb5b45A3B59d76b6926bc704Cf3cc522437;

  address public constant arbLockProxy = 0xb1E6F8820826491FCc5519f84fF4E2bdBb6e3Cad;
  address public constant arbLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60; 
  address public constant arbChainGatewayAddress = 0xA5AD439b10c3d7FBa00492745cA599250aC21619;
  address public constant arbValidatorManager = 0x2f275Df0f73649E47F1805edFfd86E6135297175;
  address public constant arbLockAndReleaseOrNativeTokenManagerUpgradeable = 0x4345472A0c6164F35808CDb7e7eCCd3d326CC50b;
  address public constant arbLockProxyTokenManager = 0x4fa6148C9DAbC7A737422fb1b3AB9088c878d26C;

  address public constant ethLockProxy = 0x9a016Ce184a22DbF6c17daA59Eb7d3140DBd1c54;
  address public constant ethLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60;
}
