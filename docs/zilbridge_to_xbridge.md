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

Zil

```
forge script script/zq/deploy/deployLockProxyProxy.s.sol --rpc-url https://api.zilliqa.com/ --broadcast --chain-id 32769 --verify  --legacy --verifier sourcify
```

-----------------

.. and set the relevant addresses in `mainnetConfig.s.sol`.

## zq

Now deploy the token managers

  * for zq, this is `02_deployZilbridgeTokenManagers.s.sol` - fill in `mainnetConfig.s.sol` and once this is verified.

  ```
forge script script/zq/deploy/02_deployZilbridgeTokenManagers.s.sol --rpc-url https://api.zilliqa.com/ --broadcast --chain-id 32769 --verify  --legacy --verifier sourcify
  ```

  * Now set up the lockproxy data

```
forge script script/zq/deploy/03_registerLockProxy.s.sol --rpc-url https://api.zilliqa.com/ --broadcast --chain-id 32769 --verify  --legacy --verifier sourcify
```


## bsc

Deploy the token managers:




## Routing


Now it's time to route between tokens and tokenmanagers on the various chains:







# NOTE! On ethereum, you can't use fees in the token manager - doing so would've cost several $1000 US in deployment fees.
