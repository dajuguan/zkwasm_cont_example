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

# Proving smoke_test of op-program client wasm image
RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params zkmain setup -k 23
RUST_LOG=info $ZKWASM --params ${WORKING_DIR}/params zkmain prove  --output ${WORKING_DIR}/output --wasm $WASM_FILE  --private $PRIVATE_FILE:file --file