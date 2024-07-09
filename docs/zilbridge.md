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


