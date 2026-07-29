#include "bit_ops.h"

namespace atlas::common {

std::uint64_t rotl64(std::uint64_t value, unsigned amount) {
  amount &= 63U;
  return (value << amount) | (value >> ((64U - amount) & 63U));
}

std::uint64_t mix64(std::uint64_t state, std::uint64_t value) {
  state ^= value + 0x9e3779b97f4a7c15ULL + (state << 6) + (state >> 2);
  state = rotl64(state, static_cast<unsigned>(value & 31U) + 1U);
  state *= 0xd6e8feb86659fd93ULL;
  state ^= state >> 29;
  state *= 0xa5b85c5e198ed849ULL;
  return state ^ (state >> 32);
}

}