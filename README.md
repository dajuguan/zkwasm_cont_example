# M1: demonstrate the zkGo compiler's ability to compile op-program client to ZK-provable Wasm

## Hardware requirements

- 1 Nvidia GPU with CUDA version >= 12.2

> [CUDA installation guide:](https://developer.nvidia.com/cuda-downloads?target_os=Linux&target_arch=x86_64&Distribution=Ubuntu&target_version=22.04&target_type=deb_local) 

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

# Hardware requirements
- Mem: >=384 Gb
- CPU: >=16 cores
- 1 Nvidia GPU with CUDA version >= 12.2
- Enable hugepage: `sudo sysctl -w vm.nr_hugepages=150000`

## Proving
Run the following command to generate 1056 trace segments, each with 2 million WASM instructions, saved as files in the `output/traces` directory. Then, generate proofs for each segment, saved as files named `output/zkmain.{*}.transcript.data`. Finally, the aggregated proof is saved as file `output/zkmain_agg.final.0.transcript.data`. The total time cost is about 20 hours.

```
bash test_cli_cont.sh
```
