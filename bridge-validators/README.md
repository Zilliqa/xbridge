# The bridge validator

This directory contains software that acts as a trivial bridge validator. It
accepts a configuration file - of which there is an example in
`config.toml` - and listens on the configured chains, relaying events
from the configured chain gateways.

The configuration is defined in `src/main.rs`.

There are a few options you can pass:

```sh
--config-file <file>   : Use this config file.

--is-leader            : if true, we will be the validator node that
                         sends transactions to the target chain.

--dispatch-history     : if true, we will go through all of history from
                         chain_gateway_block_deployed and dispatch all relay
                         transactions, to make sure we don't miss any in
                         the gap between a previous instance dying and this
                         instance starting. If false, we start at the current
                         block.

--help                 : help text.
```

## Testing information

1.Run two anvil chains:

```sh
anvil -p 8545 --chain-id 1
```

```sh
anvil -p 8546 --chain-id 2
```

2.Start:

```sh
# First account as leader
cargo run 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 -l
```

```sh
# Second account
cargo run 0x59c6995e998f97a5a0044966f0945389dc9e86dae88c7a8412f4603b6b78690d
```

2.Run `smart-contract` forge commands to test if bridge works

## Bootstrap with docker-compose

Automated bootstrap of a 4 nodes Zilliqa 2.0 aka zq2 network.

Build the images first:

```bash
docker build . -t bridge-validator-node
```

Then run:

```bash
docker-compose up
```
