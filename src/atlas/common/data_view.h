#pragma once
#include <cstddef>
#include <cstdint>

namespace atlas::common {

struct Slice {
  const std::uint8_t* data;
  std::size_t size;
};

bool read_u8(Slice input, std::size_t& offset, std::uint8_t& out);
bool read_u32(Slice input, std::size_t& offset, std::uint32_t& out);
bool read_u64(Slice input, std::size_t& offset, std::uint64_t& out);
bool read_varint(Slice input, std::size_t& offset, std::uint64_t& out);

}