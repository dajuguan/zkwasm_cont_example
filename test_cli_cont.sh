#!/bin/bash
export CUDA_VISIBLE_DEVICES=0 # for enable only one device
set -e
set -x

WKDIR=$PWD
# rm -rf output/*
cd zkWasm
cargo build --release --features perf,continuation,cuda

ZKWASM=$WKDIR/zkWasm/target/release/zkwasm-cli
WASM_FILE=$WKDIR/zkWasm/crates/zkwasm/wasm/fibonacci.wasm

# Proving smoke_test of op-program client wasm image
# RUST_LOG=info $ZKWASM --params ${WKDIR}/params fibonnaci setup -k 22
RUST_LOG=info $ZKWASM --params ${WKDIR}/params fibonnaci prove  --output ${WKDIR}/output --wasm $WASM_FILE  --public 26:i64 --file


## circuit batcher
BATCHER_DIR=$WKDIR/continuation-batcher
BATCHER=$BATCHER_DIR/target/release/circuit-batcher
BATCH_INFO_INIT=$WKDIR/sample/cont-init.json
BATCH_INFO_RECT=$WKDIR/sample/cont-rec.json
BATCH_INFO_FINAL=$WKDIR/sample/cont-final.json
cd $BATCHER_DIR
# gen solidity failed, but proof generation succeeds
# k must be 23, otherwise it'll throws not enough rows
RUST_BACKTRACE=1 cargo run --features perf,cuda --release -- --param $WKDIR/params --output $WKDIR/output batch -k 23  -s shplonk --challenge sha --info $WKDIR/output/fibonnaci.loadinfo.json --name fib_agg --commits $BATCH_INFO_INIT $BATCH_INFO_RECT $BATCH_INFO_FINAL --cont
