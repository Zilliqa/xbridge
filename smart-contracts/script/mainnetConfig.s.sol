pragma solidity ^0.8.20;

/*** @dev Inherit from this contract to get constants that tells you where other testnet contracts are.
 * I did consider structuring this a bit more closely, but there is sufficient diversity between
 * chains that I haven't,  yet.
 */
abstract contract MainnetConfig {
  address public constant bscLockProxyProxy = 0x405e42de24Dc4894dB22595D041EBb170dC21D60;
}
