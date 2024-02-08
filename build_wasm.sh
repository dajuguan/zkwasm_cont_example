#!/bin/bash
PWD=${PWD}
GOROOT=${PWD}/go
ZKGO=$GOROOT/bin/go
export GOROOT=${GOROOT}

GO_FILENAMES=("add" "fib" "goroutine")
GO_DIR=${PWD}/wasm/zkgo
WASM_DIR=${PWD}/wasm

# 1. build zkgo
echo "==Build zkgo"
rm $ZKGO
if [ -f "$ZKGO" ]; then
    echo -e "==$ZKGO exists. \n"
else
    echo "$ZKGO does not exist."
    cd $GOROOT/src
    ./all.bash
    echo -e "built \n"
fi

# 2. compile go file to wasm
for file in ${GO_FILENAMES[@]}
do
GOOS=wasip1 GOARCH=wasm $ZKGO build -ldflags="-s" -gcflags=all=-d=softfloat -o $WASM_DIR/$file.wasm $GO_DIR/$file.go
done