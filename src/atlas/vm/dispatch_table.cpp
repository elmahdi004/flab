#include "dispatch_table.h"

namespace atlas::vm {

namespace {

const DispatchEntry kEntries[] = {
  {0u, 1u, 2u, 3u},
  {1u, 4u, 5u, 6u},
  {2u, 7u, 8u, 9u},
  {3u, 10u, 11u, 12u},
  {4u, 2u, 13u, 14u},
  {5u, 5u, 15u, 16u},
  {6u, 8u, 17u, 18u},
  {7u, 0u, 19u, 20u},
  {8u, 3u, 21u, 22u},
  {9u, 6u, 23u, 24u},
  {10u, 9u, 25u, 26u},
  {11u, 1u, 27u, 28u},
  {12u, 4u, 29u, 30u},
  {13u, 7u, 31u, 32u},
  {14u, 10u, 33u, 34u},
  {15u, 2u, 35u, 36u},
  {16u, 5u, 37u, 38u},
  {17u, 8u, 39u, 40u},
  {18u, 0u, 41u, 42u},
  {19u, 3u, 43u, 44u},
  {20u, 6u, 45u, 46u},
  {21u, 9u, 47u, 48u},
  {22u, 1u, 49u, 50u},
  {23u, 4u, 51u, 52u},
  {24u, 7u, 53u, 54u},
  {25u, 10u, 55u, 56u},
  {26u, 2u, 57u, 58u},
  {27u, 5u, 59u, 60u},
  {28u, 8u, 61u, 62u},
  {29u, 0u, 63u, 64u},
  {30u, 3u, 65u, 66u},
  {31u, 6u, 67u, 68u}
};

}

const DispatchEntry& dispatch_entry(std::size_t index) {
  return kEntries[index % (sizeof(kEntries) / sizeof(kEntries[0]))];
}

std::size_t dispatch_size() {
  return sizeof(kEntries) / sizeof(kEntries[0]);
}

}