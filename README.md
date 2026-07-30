# Atlas

Atlas is a C++ binary document analysis and execution library for a compact Atlas container format. It provides two production APIs:

- inspect: parse a document and return structural summary metadata
- execute: evaluate instructions and return a deterministic execution result

This repository also includes an Atlas command-line utility for batch workflows and CI integration.

## Why Atlas Exists

Atlas is designed for teams that need deterministic document fingerprinting and execution over untrusted binary payloads in ingestion or verification pipelines. Typical uses include:

- content integrity checks in build or release pipelines
- lightweight structural validation before downstream processing
- stable execution signatures for regression monitoring

## Public API

Header: src/atlas/atlas.h

- atlas::inspect(const uint8_t* data, size_t size) -> atlas::DocumentInfo
- atlas::execute(const uint8_t* data, size_t size) -> uint32_t

## Command-Line Tool

Source: tools/atlas_cli.cpp

Usage:

```bash
atlas_cli inspect <input-file>
atlas_cli execute <input-file>
```

Output:

- inspect prints a JSON object with fingerprint, section_count, instruction_count, and string_count
- execute prints the numeric execution value

## Build Atlas CLI Locally

```bash
cd /mnt/c/Users/user/Desktop/fuzzlab
clang++ -std=c++17 -I./src tools/atlas_cli.cpp $(find src/atlas -name '*.cpp' | tr '\n' ' ') -o atlas_cli
```

## Repository Layout

```text
fuzzlab/
  src/
    atlas/
      atlas.cpp
      atlas.h
      analysis/
      common/
      format/
      io/
      vm/
  tools/
    atlas_cli.cpp
  fuzz/
    doc_fuzzer.cc
    vm_fuzzer.cc
    corpus/
      doc_fuzzer/
      vm_fuzzer/
  .clusterfuzzlite/
    build.sh
    project.yaml
```

## Quality and Fuzzing

Fuzzing is used as a robustness and security validation layer over the same Atlas library code that powers inspect and execute.

- doc_fuzzer targets the parsing and inspection path
- vm_fuzzer targets the execution path

ClusterFuzzLite build entrypoint: .clusterfuzzlite/build.sh
