#!/bin/bash -eu
mkdir -p "$OUT"
$CXX $CXXFLAGS -std=c++17 -I"$SRC/src" -c "$SRC/src/atlas/atlas.cpp" -o "$OUT/atlas.o"
$CXX $CXXFLAGS -std=c++17 "$SRC/fuzz/doc_fuzzer.cc" "$OUT/atlas.o" $LIB_FUZZING_ENGINE -I"$SRC/src" -o "$OUT/doc_fuzzer"
$CXX $CXXFLAGS -std=c++17 "$SRC/fuzz/vm_fuzzer.cc" "$OUT/atlas.o" $LIB_FUZZING_ENGINE -I"$SRC/src" -o "$OUT/vm_fuzzer"
