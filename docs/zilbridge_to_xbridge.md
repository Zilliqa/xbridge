### Zilbridge to XBridge

The deployer address is `0xD89421Cd5dD6d6269FbB9307535c386AFe11a23E`

Contract addresses are in `smart-contracts/scripts/mainnetConfig.s.sol` .

bsc: 0xD819257C964A78A493DF93D5643E9490b54C5af2
pol: 0x9121A67cA79B6778eAb477c5F76dF6de7C79cC4b
arb: 0x405e42de24Dc4894dB22595D041EBb170dC21D60
eth: 0x405e42de24Dc4894dB22595D041EBb170dC21D60



Deploy the `LockProxyProxy` to `BSC`:

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/bsc/deploy/deployLockProxyProxy.s.sol --rpc-url https://evocative-icy-arrow.bsc.quiknode.pro/1585a43e422e8f116bdc5b261c7e5eaa2efe4ca7/ --broadcast --chain-id 56 --verify
```

Now Ethereum

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/bsc/deploy/deployLockProxyProxy.s.sol --rpc-url rpc --broadcast --chain-id 56 --verify
forge verify-contract <address> --rpc-url rpc --chain-id 56
```

Polygon Amoy

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/pol/deploy/deployLockProxyProxy.s.sol --rpc-url rpc --broadcast --chain-id 56 --verify
forge verify-contract <address> --rpc-url rpc --chain-id 56
```

