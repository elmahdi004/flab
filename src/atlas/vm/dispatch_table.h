#pragma once
#include <cstdint>

namespace atlas::vm {

struct DispatchEntry {
  std::uint32_t opcode;
  std::uint32_t mode;
  std::uint32_t left;
  std::uint32_t right;
};

const DispatchEntry& dispatch_entry(std::size_t index);
std::size_t dispatch_size();

}