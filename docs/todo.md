# TODOs

1. Refactor SafeMath out of all the zilbridge takeover contracts; less
   conformant, but it's the default in 0.8.x and above.

2. The validator should check whether the transaction it proxied ran
   out of gas (meter the gas used by the subtransaction and if the
   subtxn failed and it has < 15/16, say, gas left, it probably ran
   out - try again with more gas).

3. We don't cope well when (as quite often happens) a chain (usually BSC)
   simply never confirms receipt of a transaction and we need to send it
   again (or just assume it succeeded, because although it has run, the
   chain isn't prepared to tell us this).
