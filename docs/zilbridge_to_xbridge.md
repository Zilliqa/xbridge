### Zilbridge to XBridge

The deployer address is `0xD89421Cd5dD6d6269FbB9307535c386AFe11a23E`

Deploy the `LockProxyProxy` to `BSC` (for `0x405e42de24Dc4894dB22595D041EBb170dC21D60`)

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/bsc/deploy/deployLockProxyProxy.s.sol --rpc-url rpc --broadcast --chain-id 56
forge verify-contract <address> --rpc-url rpc --chain-id 56
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

