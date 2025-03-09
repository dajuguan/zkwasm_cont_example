set -e
set -x
GOROOT=${PWD}/go
zkGo=$GOROOT/bin/go
OP_PROGRAM_CLIENT_WASM=${PWD}/optimism/op-program/bin/op-program-client-test.wasm
OP_PREIMAGE=${PWD}/wasm/preimages-test.bin
ZKWASM=$PWD/zkWasm/target/release/zkwasm-cli
ZKWASM_CONF=${PWD}/params/zkmain.zkwasm.config

# build zkGo, require current go version ^1.20
export zkGo=$zkGo
export GOROOT=$GOROOT
if [ -f "$zkGo" ]; then
    echo -e "==$zkGo exists. \n"
else
    echo "Building zkGo"
    pushd $GOROOT/src
    ./all.bash
    echo -e "zkGo built \n"
    popd
fi

# build wasm binary for op-program-client
if [ -f "$OP_PROGRAM_CLIENT_WASM" ]; then
    echo "op-program-client-test.wasm exists. \n"
else
    echo "Building op-program-client-test.wasm"
    pushd optimism/op-program
    make op-program-client-wasm-smoke-test
    popd
    cp OP_PROGRAM_CLIENT_WASM ./wasm
fi

# build zkwasm
if [ -f "$ZKWASM" ]; then
    echo "zkwasm-cli exists. \n"
else
    echo "Building zkwasm-cli"
    pushd $PWD/zkWasm
    cargo build --release --features perf,continuation,cuda
    popd
fi

# check witness file with Node.js zkwasm emulator. Require node.js version>=20.5.1
pushd optimism/op-program
echo "Check witness(preimages) with Node.js zkwasm emulator"
node ./zkWasm-emulator/wasi/wasi_exec_node.js $OP_PROGRAM_CLIENT_WASM $OP_PREIMAGE
popd

# 
if [ ! -d "./outputs" ]; then
    mkdir ./outputs
fi

if [ -f "$ZKWASM_CONF" ]; then
    echo "zkwasm has been set up. skipping"
else
    echo "setting up zkwasm. \n"
    RUST_LOG=info $ZKWASM --params ./params zkmain setup -k 22
fi

# zkWasm dry-run: run the op-program-client wasm program with zkWasm emulator in finite field
RUST_LOG=info $ZKWASM --params ./params zkmain  dry-run --wasm $OP_PROGRAM_CLIENT_WASM --private ${OP_PREIMAGE}:file --output ./outputs