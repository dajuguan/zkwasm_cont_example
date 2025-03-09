#!/bin/bash
set -e
set -x

WORKING_DIR=$PWD
ZKWASM=$PWD/zkWasm/target/release/zkwasm-cli
ZKWASM=$WORKING_DIR/zkWasm/target/release/zkwasm-cli
WASM_FILE=$WORKING_DIR/wasm/op-program-client-test.wasm
PRIVATE_FILE=$WORKING_DIR/wasm/preimages-test.bin
PROOF_NAME=zkmain

export CUDA_VISIBLE_DEVICES=0 # for enable only one device


# build wasm binary for op-program-client
if [ -f "$WASM_FILE" ]; then
    echo "op-program-client-test.wasm exists. \n"
else
    echo "Building op-program-client-test.wasm"
    pushd optimism/op-program
    make op-program-client-wasm-smoke-test
    popd
    cp ${WORKING_DIR}/optimism/op-program/bin/op-program-client-test.wasm ./wasm
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

# clean previous outputs
# rm -rf outputs/*

# prove smoke_test of op-program client wasm image
RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params ${PROOF_NAME} setup -k 23
RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params ${PROOF_NAME} prove  --output ${WORKING_DIR}/outputs --wasm $WASM_FILE  --private $PRIVATE_FILE:file --file


# aggregated proofs of zkWasm segments into one proof
BATCHER_DIR=${WORKING_DIR}/continuation-batcher
BATCHER=$BATCHER_DIR/target/release/circuit-batcher
BATCH_INFO_INIT=$BATCHER_DIR/sample/cont-init.json
BATCH_INFO_RECT=$BATCHER_DIR/sample/cont-rec.json
BATCH_INFO_FINAL=$BATCHER_DIR/sample/cont-final.json

# build zkWasm-batcher
if [ -f "$BATCHER" ]; then
    echo "zkWasm-batcher exists. \n"
else
    echo "Building zkWasm-batcher"
    pushd $BATCHER_DIR
    cargo build --release --features perf,continuation,cuda
    popd
fi

RUST_BACKTRACE=1 $BATCHER --param ${WORKING_DIR}/params --output ${WORKING_DIR}/outputs batch -k 23 -s shplonk --challenge sha --info  ${WORKING_DIR}/outputs/${PROOF_NAME}.loadinfo.json --name ${PROOF_NAME}_agg --commits $BATCH_INFO_INIT $BATCH_INFO_RECT $BATCH_INFO_FINAL --cont 11