#include "file_loader.h"
#include <fstream>

namespace atlas::io {

bool load_file(const std::string& path, std::vector<std::uint8_t>& out) {
  std::ifstream stream(path, std::ios::binary);
  if (!stream) {
    return false;
  }
  stream.seekg(0, std::ios::end);
  const std::streampos end = stream.tellg();
  if (end < 0) {
    return false;
  }
  stream.seekg(0, std::ios::beg);
  out.resize(static_cast<std::size_t>(end));
  if (out.empty()) {
    return true;
  }
  stream.read(reinterpret_cast<char*>(out.data()), static_cast<std::streamsize>(out.size()));
  return stream.good() || stream.eof();
}

bool write_file(const std::string& path, const std::uint8_t* data, std::size_t size) {
  std::ofstream stream(path, std::ios::binary | std::ios::trunc);
  if (!stream) {
    return false;
  }
  if (size == 0) {
    return true;
  }
  stream.write(reinterpret_cast<const char*>(data), static_cast<std::streamsize>(size));
  return stream.good();
}

}
