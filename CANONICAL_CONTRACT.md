# helioslang-ledger canonical contract

## Purpose and authority

I am the Koralabs copy of `@helios-lang/ledger`: the Cardano ledger types (addresses, hashes, assets and values, native scripts, signatures, transactions, network parameters, script contexts) used to decode, build, validate and serialize transactions. I hold no keys, call no network and sign nothing myself. But `helioslang-tx-utils` (the transaction chain builder and clients), `merch.handle.me` and the marketplace contracts build real transactions with me, so a wrong address, amount, fee or transaction id here becomes money sent to the wrong place or a transaction that cannot be spent. Ecosystem rules: `../AGENTS.md` (Critical Correctness). Most history is the upstream author's; review upstream syncs as behavior changes. Paths in [`.enclave`](./.enclave) need operator approval to merge.

## Invariants (must never be violated)

1. An address decodes to exactly the bytes it encodes. The bech32 checksum and network prefix are verified, a header byte or prefix that disagrees is an error, and an invalid address throws rather than decoding to a different address. (`src/address/ShelleyAddress.js`, `StakingAddress.js`, `ByronAddress.js`; tests beside each file.)
2. Token and lovelace arithmetic is exact: values add and subtract without loss, `isGreaterOrEqual` is correct per asset, and negative or non-sorted token maps are rejected where the ledger forbids them. (`src/money/`; tests `Value.test.js`, `Assets.test.js`, `AssetClass.test.js`. `Assets.subtract` itself allows negatives by design; `assertAllPositive` is the check callers must use.)
3. A native-script hash is the blake2b-224 of its CBOR with the right tag, so the policy id or address derived from a script equals the chain's. (`src/native/`; no test file in this repo covers native-script hashing directly.)
4. A decoded transaction re-encodes to exactly its original bytes, so its transaction id never changes through decode and encode, and signing it covers the body the chain will see. (`src/tx/Tx.js`, `TxBody.js`; tests "unsigned.toCbor() should give exactly the same as original encoding", "signed tx id is equal to unsigned tx id", `decodeTx`.)
5. Transaction validation fails closed: unbalanced inputs and outputs (lovelace or assets), a fee below the minimum for size, script and reference-script costs, unsorted inputs and a wrong metadata hash all throw. (`Tx.js` `validateBalanced`, `validateFee`, `validateInputsOrder`; tests "fee is larger or equal to min calculated fee", `calcRefScriptsFee`, "recovered signed doesn't fail regular validations".)
6. Signature checks use the transaction's body hash; a signature for a different body does not validate. (`src/signature/`, `TxWitnesses.js`; tests `Signature.test.js`, "unsigned tx validateSignatures fails".)
7. Only reviewed source is published: `package.json` changes only with operator approval. There is no publish workflow here; `prepack` runs the build.
8. No secrets in git.

## Boundaries and known limits

- Invariant 3 has no direct test in this repo. Invariant 6 is tested for the unsigned and not-yet-recovered cases, not for a mismatched-body signature.
- Fee checks depend on the network parameters passed in; a stale parameter set under-pays (`NetworkParamsHelper`).
- CI runs prettier, type checking, `node --test` and an integration bundle test. It does not compare outputs to a real node or to Cardano reference vectors beyond the fixtures in the tests.
- Interop with `@helios-lang/*` packages from npm (cbor, crypto, uplc) is trusted; a bug there changes my output.
- The repo's consumers pin different versions (`^0.6.x` in merch and marketplace, `^0.7.19` in tx-utils); a fix here reaches them only on their next upgrade.

## Refactors needed to enforce this

- Add native-script hash tests against known policy ids (a `sig`, an `all` and an `atLeast` script).
- Add a test that a signature over another body hash is rejected by `TxWitnesses` validation.
- Add a randomized conservation test for `Value.add`/`subtract` (round trip and per-asset totals).
- Add Cardano address reference vectors (Shelley, stake, Byron, testnet) with both valid and corrupted checksums.
