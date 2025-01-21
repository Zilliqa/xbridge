# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a
sample contract, a test for that contract, and a Hardhat Ignition
module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
```

## Scripts

### debug.ts

Prints out the balance of `TEST_ADDRESS`, given environment variables:

```sh
export TEST_ADDRESS=<address to get balance of>
export SCILLA_TOKEN_ADDRESS=<token address>
export EVM_TOKEN_ADDRESS=<tokenaddress>
```

### deploy.ts

Deploy a couple of Zilbridge "bridged to" token on Zilliqa (`SwitcheoTokenZRC2`) for testing.

```sh
export TOKEN_MANAGER_ADDRESS=<address of the token manager to be the lockproxy>
```

### transfer.ts

Transfers ZRC-2 tokens for testing - the actual transfer
`ZILBRIDGE_TEST_AMOUNT` is of `ZILBRIDGE_SCILLA_TOKEN_ADDRESS` to
`ZILBRIDGE_TEST_ADDRESS`, with environment:

```sh
export ZILBRIDGE_TEST_ADDRESS=...
export ZILBRIDGE_TEST_AMOUNT=...
export ZILBRIDGE_SCILLA_TOKEN_ADDRESS=...
```
