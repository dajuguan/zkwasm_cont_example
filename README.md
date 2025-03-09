# M1: demonstrate the [zkGo](https://github.com/ethstorage/go/tree/zkGo) compiler's ability to compile [op-program client](https://github.com/ethstorage/optimism/tree/js-io/op-program/client) to ZK-provable Wasm image

## Hardware requirements

- 1 Nvidia GPU with CUDA version >= 12.2

> [CUDA installation guide](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local) 

## Software dependencies

- Go: ^1.20.0 (gvm use go1.20.7)
- Node.js: ^20.5.1
- Rustc: ^1.76.0

## Steps for compiling the op-program into a Wasm image and running it with the zkWasm emulator
```
# check cuda version
nvcc -V
# check go version
go version
# check node.js verison
node -v
# check cargo version
cargo -V

git clone -b smoke_test https://github.com/dajuguan/zkwasm_cont_example.git
cd zkwasm_cont_example
git submodule update --init --recursive
# Don't forget to set go version: gvm use go 1.20.7
bash cli_dry_run.sh
```

# M2: demo of proving op-program’s derivation in a simplified setup using zkWasm

## Hardware requirements
- Mem: >=384 Gb
- CPU: >=16 cores
- 1 Nvidia GPU with CUDA version >= 12.2
- Enable hugepage: `sudo sysctl -w vm.nr_hugepages=150000`

## Software dependencies
- Rustc: ^1.76.0

## Prove op-program client wasm image with [zkWasm](https://github.com/DelphinusLab/zkWasm) and aggregate the proofs with [zkWasm-batcher](https://github.com/DelphinusLab/continuation-batcher)
Run the following command to generate 1056 trace segments, each with 2 million WASM instructions, saved as files in the `outputs/traces` directory. Then, generate proofs for each segment, saved as files named `outputs/zkmain.{*}.transcript.data`. Finally, the aggregated proof is saved as file `outputs/zkmain_agg.final.0.transcript.data`. The total time cost is **about 20 hours**.

```
# check huges pages == 150000
grep HugePages_Total /proc/meminfo
# check cuda version ^12.2
nvcc -V
# check cargo version
cargo -V

bash cli_cont.sh
```

# References  
- **Progress in OP Stack ZK Proof by EthStorage, Hyper Oracle, and Delphinus Lab**  
    - [zkGo and op-program client adaptation with conditional compilation](https://github.com/ethereum-optimism/ecosystem-contributions/issues/61#issuecomment-1734874805)  
    - [Continuation Proving System, Keccak Host Circuit Implementation, and Trace Generation Optimization](https://github.com/ethereum-optimism/ecosystem-contributions/issues/61#issuecomment-1880383180)  
    - [E2E demo of proving op-program client](https://github.com/ethereum-optimism/ecosystem-contributions/issues/61#issuecomment-2216370869)  
- [Advancing Towards ZK Fraud Proof - zkGo](https://perfect-amphibian-929.notion.site/Advancing-Towards-ZK-Fraud-Proof-zkGo-Compiling-L2-Geth-into-ZK-Compatible-Wasm-315a878af5754c549e5003568e1ee124)  
- [ZKWASM Book](https://zkwasmdoc.gitbook.io/delphinus-zkwasm)