package main

//go:wasmimport env wasm_output
//go:noescape
func wasm_output(uint64)

func main() {
	a := uint64(1) + uint64(2)
	wasm_output(a)
}
