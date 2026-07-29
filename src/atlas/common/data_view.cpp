#include "data_view.h"

namespace atlas::common {

bool read_u8(Slice input, std::size_t& offset, std::uint8_t& out) {
  if (offset >= input.size) {
    return false;
  }
  out = input.data[offset++];
  return true;
}

bool read_u32(Slice input, std::size_t& offset, std::uint32_t& out) {
  if (offset + 4 > input.size) {
    return false;
  }
  std::uint32_t value = 0;
  value |= static_cast<std::uint32_t>(input.data[offset + 0]) << 0;
  value |= static_cast<std::uint32_t>(input.data[offset + 1]) << 8;
  value |= static_cast<std::uint32_t>(input.data[offset + 2]) << 16;
  value |= static_cast<std::uint32_t>(input.data[offset + 3]) << 24;
  offset += 4;
  out = value;
  return true;
}

bool read_u64(Slice input, std::size_t& offset, std::uint64_t& out) {
  if (offset + 8 > input.size) {
    return false;
  }
  std::uint64_t value = 0;
  for (int i = 0; i < 8; ++i) {
    value |= static_cast<std::uint64_t>(input.data[offset + static_cast<std::size_t>(i)]) << (8 * i);
  }
  offset += 8;
  out = value;
  return true;
}

bool read_varint(Slice input, std::size_t& offset, std::uint64_t& out) {
  std::uint64_t value = 0;
  unsigned shift = 0;
  for (unsigned i = 0; i < 10; ++i) {
    std::uint8_t byte = 0;
    if (!read_u8(input, offset, byte)) {
      return false;
    }
    value |= static_cast<std::uint64_t>(byte & 0x7fU) << shift;
    if ((byte & 0x80U) == 0) {
      out = value;
      return true;
    }
    shift += 7;
  }
  return false;
}

}