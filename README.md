# Ledger

## Contributor test policy

Tests and coverage run locally only, never in GitHub Actions, including indirect lifecycle, composite, template, and shared-helper execution. `build` and `prepack` invoke tests here and are local-only unless the graph is separated. Preserve local scripts. Build-only automation, publication, deployment, and production guards remain permitted; retire obsolete required test checks.

Types and classes needed for the mainnet ledger:
* Address
* AssetClass
* Block
* DCert
* Hashes
* PoolParameters
* PoolRelay
* TimeRange
* Tx
* TxInput
* TxOutput
* Value
* etc.


Eras:
1. Byron
2. Shelley
3. Allegra 
4. Mary
5. Alonzo
6. Babbage
7. Conway
