# TODOs

1. Refactor SafeMath out of all the zilbridge takeover contracts; less conformant, but it's the default in 0.8.x and above.
2. The validator should check whether the transaction it proxied ran out of gas (meter the gas used by the subtransaction and if the subtxn failed and it has < 15/16, say, gas left, it probably ran out - try again with more gas).
