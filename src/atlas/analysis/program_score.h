#pragma once
#include <cstddef>
#include <cstdint>

namespace atlas::analysis {

struct ProgramScore {
  std::uint64_t fingerprint;
  std::uint32_t section_score;
  std::uint32_t string_score;
  std::uint32_t instruction_score;
};

ProgramScore score_bytes(const std::uint8_t* data, std::size_t size);

}