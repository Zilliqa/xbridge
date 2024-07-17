# Zilbridge/XBridge integration


## CrossChainManager extensions

The currently deployed CCM on Ethereum does not contain functions to register lockProxy extensions.

These can be run remotely from the `counterpartChainId` (in `lockProxy`), currently set to 5 (which is presumably Carbon).

This means we need to either proxy or replace it.

Replacing it is undesirable, because the address of the CCM is baked into the configuration files for the relayers.

My first attempt was to proxy it with a `CCMExtendProxy`, but this doesn't work, because:

 * To upgrade you have to call `ccmProxy::upgradeEthCrossChainManager()`
 * (side-note: this calls the _current_ `eccm.upgradeToNew()` which hands ownership of the CCM data (proxied by the CCM contract) to the CCMExtendProxty, which now needs to hand it back to the old `ccm`)
 * Subsequent calls through the `CCMExtendProxy` need to use the original `ccm` state, and therefore have the `CCMExtendProxy` as `msg.sender`.
 * But there is no way to make the `CCMExtendProxy` an owner of the `ccm`.

The second attempt is to write a new CCM contract which duplicates the
original CCM and contains the new functions. Sadly, this means that
someone needs to remember what the whitelist parameters were, because
it is a map that does not emit events and we thus can't work out what
is in it.

## LockProxyTokenManager

There is a `LockProxyTokenManager` which is registered as an extension and interacts with the lock proxy to bridge tokens. 

zilBridge itself doesn't know which tokens are mint/burn and which are
lock/release - the lockproxy simply transfers tokens to and from
itself and the contracts it talks to either mint and burn, or don't,
when they spot that it's the lock proxy asking.

We test it against a stubbed out LockProxyTokenManager which apes what the
Scilla side will do eventually, but with stubbed interop calls.

## Current outstanding issues

### Parallel ZilBridge operations

If we can't get someone (Polynet?) to install our extension remotely,
we will have to replace the non-Zilliqa `ccm` and this will break
ZilBridge. Polynet will have to reset their `ccm` address to recover
functionality.

If we do replace the non-Zilliqa `ccm`, I suggest that we do so with a
CCM that doesn't accept cross-chain events; this will make sure that
old keys from zilbridge/polynet can't compromise us in the future.

### Native ZIL operations

It's not possible to send native tokens via interop calls on
Zilliqa. Thus, the only way to unwrap wrapped ZIL is natively.

Because signature verification is carried out on chain, we can't easily modify the verifier to make native calls.

So, the best we can do is to:

 * Issue a wrapped ZIL (`wZIL` itself is owned by Jun Hao - we could take over)
 * Withdraw all the ZIL from the `lockProxy` and deposit it in wZIL
 * Give that wZIL to the `lockProxy`
 * Register wZIL as the `lockProxy` corresponding token for wrapped ZIL on other chains.
 * `lockProxy` will then give you `wZIL` for your wrapped ZIL on other chains and you can issue a native call to get ZIL back for it.

Unfortunately, we have to live (probably permanently unless we can
think of a way around it) with `lockProxy` accepting ZIL - if you send
your ZIL to `lockProxy`, we will have to recover it for you with our
admin rights, because obviously you won't be able to bridge it to
anywhere else.

##  BSC Testnet Deployment

There are a group of scripts that allow you to deploy the EVM half of the ZilBridge transition code into BSC Testnet.

The `smart-contracts/README.md` contains predeployed addresses; if you
decide to redeploy you will need to change the constants in the `
scripts, since this is how the addresses of previous contracts are
baked in (sorry!).

Set `PRIVATE_KEY_TESTNET` to the validator privkey, and `PRIVATE_KEY_ZILBRIDGE` to the zilbridge owner privkey.
Run with:

```sh
forge script script/bsc-testnet/deployMockZilBridge.s.sol --rpc-url https://bsc-testnet.bnbchain.org --broadcast

forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org --chain-id 97
# Now fill in the data to test_config.s.sol
forge script script/bsc-testnet/deployXBridgeOverMockZilBridge.s.sol --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org --chain-id 97
# and again ..
forge script scripts/bsc-testnet/deployZilBridgeTokenManagers.s.sol --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org --chain-id 97
# and again..
forge script script/bsc-testnet/deployZilBridgeTokens.s.sol --tc Deployment --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org --chain-id 97

```

Remember to verify all your contracts on BSC, or you will get hopelessly confused later.

Now we need to deploy some contracts on the Zilliqa testnet. 

We'll need our own token manager. This is identical to the
`LockAndReleaseTokenManager`, but contains some additional
functionality to deal with bridging native tokens (so that bridged ZIL
can be made to work).


```
forge script script/zq-testnet/deployNativeTokenManagerV3.s.sol --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
forge script script/zq-testnet/setChainGatewayOnTokenManager.s.sol --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

Now we can deploy a couple of tokens to the Zilliqa testnet. We'll deploy two Switcheo ZRC-2s - one for testing BSC testnet ERC20s and one for BSC testnet native tokens, and an ordinary ZRC-2. 

```
cd scilla-contracts
pnpm i
export TOKEN_MANAGER=(whatever address the deployNativeTokenManagerV3 script above gave you)
npx hardhat run scripts/deploy.ts
```

And now we can set up routing for the tokens we just deployed. This is "just" calls, so 

```
forge script script/bsc-testnet/setZilBridgeRouting.s.sol --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge script script/zq-testnet/setZilBridgeRouting.s.sol --rpc-url https://bsc-testnet.bnbchain.org --broadcast
```il



## TODO

 - Move the test code for zilbrige into `test/`
 - Refactor out `SafeMath` etc. - we could have only one copy of these (probably!)
