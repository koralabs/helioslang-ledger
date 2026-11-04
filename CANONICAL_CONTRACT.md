# helioslang-ledger canonical contract

I am the Koralabs copy of `@helios-lang/ledger`: Cardano ledger types (addresses, hashes, assets and values, native scripts, signatures, transactions, network parameters, script contexts) used to decode, build, validate and serialize transactions. I hold no keys, call no network and sign nothing.

1. **An address decodes to exactly the bytes it encodes.** Bech32 checksum and network prefix are verified, a disagreeing header byte or prefix is an error, and an invalid address throws rather than decoding to a different one.
2. **Token and lovelace arithmetic is exact.** Values add and subtract without loss, `isGreaterOrEqual` is correct per asset, and the ledger-forbidden negative or unsorted token maps are rejected (`Assets.subtract` allows negatives by design; callers use `assertAllPositive`).
3. **A native-script hash is the blake2b-224 of its CBOR with the right tag,** so a derived policy id or address equals the chain's.
4. **A decoded transaction re-encodes to exactly its original bytes,** so its id never changes through decode and encode.
5. **Transaction validation fails closed.** Unbalanced inputs/outputs, a fee below the minimum, unsorted inputs and a wrong metadata hash throw.
6. **A signature for a different body hash does not validate.**
