#include "program_score.h"
#include "../common/bit_ops.h"

namespace atlas::analysis {

ProgramScore score_bytes(const std::uint8_t* data, std::size_t size) {
  std::uint64_t state = 0x1234abcd6789ef01ULL;
  std::uint32_t section_score = 0;
  std::uint32_t string_score = 0;
  std::uint32_t instruction_score = 0;
  for (std::size_t i = 0; i < size; ++i) {
    std::uint64_t value = static_cast<std::uint64_t>(data[i]) + (static_cast<std::uint64_t>(i) << 8);
    state = common::mix64(state, value);
    section_score += static_cast<std::uint32_t>((data[i] & 3U) + 1U);
    string_score += static_cast<std::uint32_t>((data[i] >> 2) & 7U);
    instruction_score ^= static_cast<std::uint32_t>(common::rotl64(state, data[i] & 31U));
  }
  return ProgramScore{state, section_score, string_score, instruction_score};
}

}