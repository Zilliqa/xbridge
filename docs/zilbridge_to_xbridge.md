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
forge script script/bsc/deploy/deployLockProxyProxy.s.sol --rpc-url ${BSC_RPC_URL} --broadcast --chain-id 56 --verify
```

Now Ethereum

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/bsc/deploy/deployLockProxyProxy.s.sol --rpc-url rpc --broadcast --chain-id 56 --verify
forge verify-contract <address> --rpc-url rpc --chain-id 56
```

Polygon 

```
export PRIVATE_KEY_OWNER=<p>
export ETHERSCAN_API_KEY=<p>
forge script script/pol/deploy/deployLockProxyProxy.s.sol --rpc-url rpc --broadcast --chain-id 137  --verify
forge verify-contract <address> --rpc-url rpc --chain-id 137
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
forge script script/zq/deploy/02_deployZilbridgeTokenManagers.s.sol --rpc-url https://api.zilliqa.com/ --broadcast --chain-id 32769 --verify  --legacy --verifier sourcify --
  ```

  * Now set up the lockproxy data

```
forge script script/zq/deploy/03_registerLockProxy.s.sol --rpc-url https://api.zilliqa.com/ --broadcast --chain-id 32769 --verify  --legacy --verifier sourcify
```


## bsc

Same as `zq`:

```
export ETHERSCAN_API_KEY=...
export BSC_RPC_URL=..
forge script script/bsc/deploy/02_deployZilbridgeTokenManagers.s.sol --rpc-url ${BSC_RPC_URL} --broadcast --chain-id 56 --verify  --legacy
forge script script/bsc/deploy/03_registerLockProxy.s.sol --rpc-url ${BSC_RPC_URL} --broadcast --chain-id 56 --verify  --legacy
```

## pol, arb

These requires the core to be deployed as well as the token managers; just run the deployments one by one.

```
export ETHERSCAN_API_KEY=...
export POL_RPC_URL=..
forge script script/pol/deploy/02_deployCoreUpgradeable.s.sol --rpc-url ${POL_RPC_URL} --broadcast --chain-id 137 --verify
```


```
forge script script/arb/deploy/04_registerTokenManagers.s.sol --rpc-url ${ARB_RPC_URL} --broadcast --chain-id 42161 --verify
```



## Routing


Now it's time to route between tokens and tokenmanagers on the various chains:







# NOTE! On ethereum, you can't use fees in the token manager - doing so would've cost several $1000 US in deployment fees.
