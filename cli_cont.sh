#!/bin/bash
export CUDA_VISIBLE_DEVICES=0 # for enable only one device
set -e
set -x

WORKING_DIR=$PWD
# rm -rf output/*
cd zkWasm
cargo build --release --features perf,continuation,cuda


ZKWASM=$WORKING_DIR/zkWasm/target/release/zkwasm-cli
WASM_FILE=$WORKING_DIR/wasm/op-program-client-test.wasm
PRIVATE_FILE=$WORKING_DIR/wasm/preimages-test.bin
PROOF_NAME=zkmain

# Proving smoke_test of op-program client wasm image
# RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params ${PROOF_NAME} setup -k 23
# RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params ${PROOF_NAME} prove  --output ${WORKING_DIR}/output --wasm $WASM_FILE  --private $PRIVATE_FILE:file --file


# Aggregated proofs of zkWasm segments into one proof
BATCHER_DIR=${WORKING_DIR}/continuation-batcher
BATCHER=$BATCHER_DIR/target/release/circuit-batcher
BATCH_INFO_INIT=$BATCHER_DIR/sample/cont-init.json
BATCH_INFO_RECT=$BATCHER_DIR/sample/cont-rec.json
BATCH_INFO_FINAL=$BATCHER_DIR/sample/cont-final.json

cd $BATCHER_DIR
RUST_BACKTRACE=1 cargo run --release --features perf,cuda -- --param ${WORKING_DIR}/params --output ${WORKING_DIR}/output batch -k 23 -s shplonk --challenge sha --info  ${WORKING_DIR}/output/${PROOF_NAME}.loadinfo.json --name ${PROOF_NAME}_agg --commits $BATCH_INFO_INIT $BATCH_INFO_RECT $BATCH_INFO_FINAL --cont 11