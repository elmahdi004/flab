#pragma once
#include <cstdint>

namespace atlas::common {

std::uint64_t rotl64(std::uint64_t value, unsigned amount);
std::uint64_t mix64(std::uint64_t state, std::uint64_t value);

}