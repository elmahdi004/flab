# fuzzlab

Private C++ fuzzing repository for Atlas parsing and VM execution paths.

## Overview

This repository contains:

- Atlas core implementation in `src/atlas`
- Two libFuzzer harnesses in `fuzz/`
  - `doc_fuzzer.cc` for document inspection flow
  - `vm_fuzzer.cc` for execution flow
- Seed corpus in `fuzz/corpus/`
- ClusterFuzzLite build entrypoint in `.clusterfuzzlite/build.sh`

## Repository Layout

```
fuzzlab/
  .clusterfuzzlite/
    build.sh
    project.yaml
  fuzz/
    doc_fuzzer.cc
    vm_fuzzer.cc
    corpus/
      doc_fuzzer/
      vm_fuzzer/
  src/
    atlas/
      atlas.cpp
      atlas.h
      analysis/
      common/
      format/
      vm/
  generate_atlas.ps1
```
