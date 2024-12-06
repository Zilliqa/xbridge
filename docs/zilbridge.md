# Zilbridge/XBridge integration

Note that this work was done referencing the ZilBridge 1 contracts
available on Ethereum Mainnet (which have been verified - hence the
rather horrid source).

Other contracts on the other correspondent chains of ZilBridge are
only patchily verified, and the ones that are verified are different
from those on Ethereum; the same approach should work, but I can't
guarantee it. Proceed with caution.

## CrossChainManager extensions

The currently deployed CCM on Ethereum does not contain functions to
register lockProxy extensions.

These can be run remotely from the `counterpartChainId` (in
`lockProxy`), currently set to 5 (which is presumably Carbon).

This means we need to either proxy or replace it.

Replacing it is undesirable, because the address of the CCM is baked
into the configuration files for the relayers.

My first attempt was to proxy it with a `CCMExtendProxy`, but this
doesn't work, because:

- To upgrade you have to call `ccmProxy::upgradeEthCrossChainManager()`
- (side-note: this calls the _current_ `eccm.upgradeToNew()` which
  hands ownership of the CCM data (proxied by the CCM contract) to
  the CCMExtendProxty, which now needs to hand it back to the old
  `ccm`)
- Subsequent calls through the `CCMExtendProxy` need to use the
  original `ccm` state, and therefore have the `CCMExtendProxy` as
  `msg.sender`.
- But there is no way to make the `CCMExtendProxy` an owner of the
  `ccm`.

The second attempt is to write a new CCM contract which duplicates the
original CCM and contains the new functions. Sadly, this means that
someone needs to remember what the whitelist parameters were, because
it is a map that does not emit events and we thus can't work out what
is in it.

If we have the ability to register extensions directly over the
bridge, then all the faff with `CCMExtendProxy` is unnecessary and we
can directly register `LockProxyTokenManager` as an extension.

If we do have to use `CCMExtendProxy`, it might be wise to remove the
bridge functions for release, to exclude any bugs in them from our
security perimeter.

We'll have to discuss this when we come to migrate ZilBridge.

## LockProxyTokenManager

There is a `LockProxyTokenManager` which is registered as an extension
and interacts with the lock proxy to bridge tokens.

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

## Testnet Deployment with Zilliqa Testnet and BSC testnet

There are a group of scripts that allow you to deploy the EVM half of
the ZilBridge transition code into BSC Testnet.

The `smart-contracts/README.md` contains predeployed addresses; if you
decide to redeploy you will need to change the constants in the `
scripts, since this is how the addresses of previous contracts are
baked in (sorry!).

Set `PRIVATE_KEY_TESTNET` to the validator privkey, and
`PRIVATE_KEY_ZILBRIDGE` to the zilbridge owner privkey.

After each step (each script run) in the below, you will need to:

- Verify the contracts you just deployed.
- Update the `testnet_config.s.sol` file with the addresses of the
  contracts you just deployed.

In most cases, the script will give you the name of the
`testnet_config.s.sol` constant to update.

Run with:

```sh
forge script script/bsc-testnet/deployMockZilBridge.s.sol \
   --rpc-url https://bsc-testnet.bnbchain.org --broadcast

forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org \
  --chain-id 97
# Now fill in the data to test_config.s.sol
forge script script/bsc-testnet/deployXBridgeOverMockZilBridge.s.sol \
   --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org \
  --chain-id 97

```

Remember to verify all your contracts on BSC, or you will get
hopelessly confused later.

Now we need to deploy some contracts on the Zilliqa testnet. You can
verify on Zilliqa via sourcify:

```sh
forge verify-contract <address> --rpc-url https://dev-api.zilliqa.com \
  --chain-id 33101 --verifier sourcify
```

We'll need our own token manager. This is identical to the
`LockAndReleaseTokenManager`, but contains some additional
functionality to deal with bridging native tokens (so that bridged ZIL
can be made to work).

```sh
forge script script/zq-testnet/deployNativeTokenManagerV3.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
forge script script/zq-testnet/setChainGatewayOnTokenManager.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

Now we can deploy some contracts to the BNB testnet:

```sh
forge script script/bsc-testnet/deployZilBridgeTokens.s.sol \
  --tc Deployment --rpc-url https://bsc-testnet.bnbchain.org \
  --broadcast
```

And, once we've recorded the token addresses (so that the
`LockProxyProxy` knows about them):

```
forge script scripts/bsc-testnet/deployZilBridgeTokenManagers.s.sol \
  --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org \
  --chain-id 97
forge verify-contract <address> --rpc-url https://bsc-testnet.bnbchain.org \
  --chain-id 97
```

And the corresponding tokens to the Zilliqa testnet:

```sh
cd scilla-contracts
pnpm i
export TOKEN_MANAGER_ADDRESS=(value of zq_lockAndReleaseOrNativeTokenManager)
# NOW EDIT scripts/deploy.ts for the address of the Zilliqa testnet token manager.
npx hardhat run scripts/deploy.ts --network zq_testnet
```

And now we ship an ERC20 proxy for our ZRC2 and switcheo tokens.

```sh
forge script script/zq-testnet/deployZRC2ERC20.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

And now we can set up routing for the tokens we just deployed. This is
"just" calls, so

```sh
forge script script/bsc-testnet/setZilBridgeRouting.s.sol \
  --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge script script/zq-testnet/setZilBridgeRouting.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

### Testing

The CI/CD'd testnet relayer will work for you.

You can run the web interface with the instructions in [bridge-web/README.md](bridge-web/README.md).

To avoid running into CORS problems, you will need to:

```sh
export VITE_BSC_TESTNET_API=http://localhost:6128
export VITE_BSC_TESTNET_KEY=""
```

Remember to omit the trailing '/' from `VITE_BSC_TESTNET_API` or you
will get CORS errors.

And run:

```sh
mitmweb --mode reverse:https://data-seed-prebsc-1-s1.binance.org:8545/ \
  --no-web-open-browser --listen-port 6128 --web-port 6001
```

Put the token and token manager addresses from `testnet_config.s.sol`
into `bridge-web/src/config/config.ts` .

You can transfer yourself some tokens by setting
`ZILBRIDGE_TEST_ADDRESS` and `ZILBRIDGE_TEST_AMOUNT` and running:

```sh
forge script script/bsc-testnet/zilBridgeTransferERC20.s.sol \
  --rpc-url https://bsc-testnet.bnbchain.org --broadcast
```

And, setting `ZILBRIDGE_SCILLA_TOKEN_ADDRESS` to the Scilla token address:

```sh
npx hardhat run scripts/transfer.ts
```

The ZQ transfer needs to be ZRC-2 because the initial funds holder is
the Zilliqa account associated with `PRIVATE_KEY_ZILBRIDGE` and we
therefore need a Scilla transition to transfer them.

There is a test case template in
`docs/zilbridge_test_template.md`. Copy it for your commit and fill it
in.

### Debugging from-zilliqa transfers

Since Zilliqa testnet doesn't support tracing, this is done by
bisection. You only need one way, since we only care about the sending
txn working.

- Redeploy the token manager on ZQ:

```sh
forge script script/zq-testnet/deployNativeTokenManagerV3.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
<edit config>
forge script script/zq-testnet/setChainGatewayOnTokenManager.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
forge verify-contract <address> --rpc-url https://dev-api.zilliqa.com \
 --chain-id 33101
```

Now write some routing - it actually doesn't matter that the routing
gets messed up, because we're only testing Zilliqa ZRC2 out, and the
native ZRC2 doesn't care what the token manager is:

```sh
forge script script/zq-testnet/setZilBridgeRouting.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

- Run `transfer.ts` to transfer some `ZBTEST` to the wallet you want to test.
- List the new token manager in `config.ts` in `bridge-web`

Now you can send a `transfer()` request and see if it works .. you'll
need to redeploy the test token contracts and rerun routing setup
(from both sides!) to fix the bridge when the bugs are sorted.

When you're done, you'll need to redeploy the rest of the tokens, so
that the bridged ZRC2 has the right token manager set, then set up
routing again:

```sh
cd scilla-contracts
pnpm i
export TOKEN_MANAGER_ADDRESS=(value of
  zq_lockAndReleaseOrNativeTokenManager WITHOUT 0x prefix)

# NOW EDIT scripts/deploy.ts for the address of the
# Zilliqa testnet token manager.
npx hardhat run scripts/deploy.ts --network zq_testnet
```

Remember to update `testnet_config.sol`, then:

```sh
forge script script/zq-testnet/deployZRC2ERC20.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
forge script script/bsc-testnet/setZilBridgeRouting.s.sol \
  --rpc-url https://bsc-testnet.bnbchain.org --broadcast
forge script script/zq-testnet/setZilBridgeRouting.s.sol \
  --rpc-url https://dev-api.zilliqa.com --broadcast --legacy
```

And you can now get testing again.
