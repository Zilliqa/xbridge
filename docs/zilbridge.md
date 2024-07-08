# Zilbridge/XBridge integration


## CrossChainManager extensions

The CCM contains state; the current approach to retaining this state
is to replace the ccm in the ccmProxy with a shim contract that
forwards requests to the underlying contract but additionally allows
an owner to register extensions.

This works, and has the advantage that you don't need to change the
address of the ccm baked into the relayers, but it breaks the
invariant that cross-chain events come from the contract referred to
by the ccmProxy. If there is software that reads the address of the
CCM from the ccmProxy and then expects cross-chain events to come from
it, we will need to replace the ccm entirely.

This is not as straightforward as it looks because the deployed CCM on
ethereum is quite old and we would need to test that it still works
with zilBridge 1 when upgraded or updated for a reasonably modern
solidity version.


