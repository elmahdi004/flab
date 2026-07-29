#include "input_cursor.h"

namespace atlas::format {

bool next_token(InputCursor& cursor, std::string& out) {
  while (cursor.offset < cursor.size && cursor.data[cursor.offset] <= 0x20U) {
    ++cursor.offset;
  }
  std::size_t start = cursor.offset;
  while (cursor.offset < cursor.size && cursor.data[cursor.offset] > 0x20U) {
    ++cursor.offset;
  }
  if (start == cursor.offset) {
    return false;
  }
  out.assign(reinterpret_cast<const char*>(cursor.data + start), cursor.offset - start);
  return true;
}

bool next_bytes(InputCursor& cursor, std::size_t length, std::string& out) {
  if (length > cursor.size - cursor.offset) {
    return false;
  }
  out.assign(reinterpret_cast<const char*>(cursor.data + cursor.offset), length);
  cursor.offset += length;
  return true;
}

}