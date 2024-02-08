#!/bin/bash
set -e

PWD=${PWD}
WASM_DIR=$PWD/wasm
WASM_IAMGES=("add" "fib" "goroutine")

ZKWASM_DIR=${PWD}/zkWasm/
OUTPUT=${PWD}/output
ZKWASM=$ZKWASM_DIR/target/release/delphinus-cli

BATCHER_DIR=${PWD}/continuation-batcher
BATCHER=$BATCHER_DIR/target/release/circuit-batcher
CONT_BATCH_INFO=$BATCHER_DIR/sample/batchinfo_cont.json

# 1. build zkWasm & batcher
if [ -f "$ZKWASM" ]; then
    echo "$ZKWASM exist."
else
    echo "==$ZKWASM does not exist, building..."
    cd $ZKWASM_DIR
    git submodule update --init
    cargo build --release --features continuation,cuda
    echo "==$ZKWASM built."
fi

if [ -f "$BATCHER" ]; then
    echo "$BATCHER exist."
else
    echo "==$BATCHER does not exist, building..."
    cd $BATCHER_DIR
    cargo build --release --features cuda
    echo "==$BATCHER built."
fi

export RUST_LOG=info

for NAME in ${WASM_IAMGES[@]}
do
if [ ! -d $PWD/output/$NAME ];then
mkdir -p $PWD/output/$NAME
fi
echo $NAME
# $ZKWASM --params $PWD/params simple_add dry-run --wasm $WASM_DIR/$NAME.wasm --output $PWD/output/$NAME
OUTPUT_DIR=$PWD/output/$NAME
$ZKWASM --params $PWD/params $NAME setup
$ZKWASM --params $PWD/params $NAME prove --wasm $WASM_DIR/$NAME.wasm --output $OUTPUT_DIR
$BATCHER --param $PWD/params --output $OUTPUT_DIR batch -k 22 --challenge sha --info  $OUTPUT_DIR/$NAME.loadinfo.json --name ${NAME}_agg --commits $CONT_BATCH_INFO --cont
done
