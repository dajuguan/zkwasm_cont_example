# Proving smoke_test case of op-program client with zkWasm

## Hardware requirements
- Mem: >=384 Gb
- CPU: >=16 cores
- 1 Nvidia GPU with CUDA version >= 12.4
- Enable hugepage: `sudo sysctl -w vm.nr_hugepages=150000`

## Proving
Run the following command to generate 1056 trace segments, each with 2 million WASM instructions, saved as files in the `output/traces` directory. Then, generate proofs for each segment, saved as files named `output/zkmain.{*}.transcript.data`. Finally, the aggregated proof is saved as file `output/zkmain_agg.final.0.transcript.data`. The total time cost is about 20 hours.

```
bash test_cli_cont.sh
```
