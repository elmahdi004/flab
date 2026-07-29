#pragma once
#include <cstddef>
#include <cstdint>
namespace atlas {
struct DocumentInfo {
  std::uint64_t fingerprint;
  std::size_t section_count;
  std::size_t instruction_count;
  std::size_t string_count;
};
DocumentInfo inspect(const std::uint8_t* data, std::size_t size);
std::uint32_t execute(const std::uint8_t* data, std::size_t size);
}
