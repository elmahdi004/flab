#pragma once
#include <cstddef>
#include <cstdint>
#include <string>

namespace atlas::format {

struct InputCursor {
  const std::uint8_t* data;
  std::size_t size;
  std::size_t offset;
};

bool next_token(InputCursor& cursor, std::string& out);
bool next_bytes(InputCursor& cursor, std::size_t length, std::string& out);

}