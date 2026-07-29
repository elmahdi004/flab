#include "../src/atlas/atlas.h"
#include <cstddef>
#include <cstdint>
extern "C" int LLVMFuzzerTestOneInput(const std::uint8_t* data, std::size_t size) {
  (void)atlas::execute(data, size);
  return 0;
}
