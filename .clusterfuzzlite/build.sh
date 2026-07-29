#!/bin/bash -eu
mkdir -p "$OUT"
objects=()
while IFS= read -r source; do
	relative=${source#"$SRC/src/"}
	object="$OUT/${relative//\//_}.o"
	$CXX $CXXFLAGS -std=c++17 -I"$SRC/src" -c "$source" -o "$object"
	objects+=("$object")
done < <(find "$SRC/src/atlas" -name '*.cpp' | sort)
$CXX $CXXFLAGS -std=c++17 "$SRC/fuzz/doc_fuzzer.cc" "${objects[@]}" $LIB_FUZZING_ENGINE -I"$SRC/src" -o "$OUT/doc_fuzzer"
$CXX $CXXFLAGS -std=c++17 "$SRC/fuzz/vm_fuzzer.cc" "${objects[@]}" $LIB_FUZZING_ENGINE -I"$SRC/src" -o "$OUT/vm_fuzzer"
