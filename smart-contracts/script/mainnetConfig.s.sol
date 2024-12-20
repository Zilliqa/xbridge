pragma solidity ^0.8.20;

/*** @dev Inherit from this contract to get constants that tells you where other testnet contracts are.
 * I did consider structuring this a bit more closely, but there is sufficient diversity between
 * chains that I haven't,  yet.
 */
abstract contract MainnetConfig {
  address public constant bscLockProxyProxy = 0xD819257C964A78A493DF93D5643E9490b54C5af2;

  
  address public constant polLockProxyProxy = 0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b;
  address public constant arbLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60;
  address public constant ethLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60;

  
}
