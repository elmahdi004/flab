#include "../src/atlas/atlas.h"
#include "../src/atlas/io/file_loader.h"
#include <cstdint>
#include <iostream>
#include <string>
#include <vector>

namespace {

void print_usage() {
  std::cout << "Atlas CLI\n";
  std::cout << "Usage:\n";
  std::cout << "  atlas_cli inspect <input-file>\n";
  std::cout << "  atlas_cli execute <input-file>\n";
}

int run_inspect(const std::vector<std::uint8_t>& bytes) {
  const atlas::DocumentInfo info = atlas::inspect(bytes.data(), bytes.size());
  std::cout << "{\"fingerprint\":" << info.fingerprint
            << ",\"section_count\":" << info.section_count
            << ",\"instruction_count\":" << info.instruction_count
            << ",\"string_count\":" << info.string_count << "}\n";
  return 0;
}

int run_execute(const std::vector<std::uint8_t>& bytes) {
  const std::uint32_t value = atlas::execute(bytes.data(), bytes.size());
  std::cout << value << "\n";
  return 0;
}

}

int main(int argc, char** argv) {
  if (argc != 3) {
    print_usage();
    return 1;
  }
  const std::string mode(argv[1]);
  const std::string path(argv[2]);
  std::vector<std::uint8_t> bytes;
  if (!atlas::io::load_file(path, bytes)) {
    std::cerr << "failed to read input file\n";
    return 2;
  }
  if (mode == "inspect") {
    return run_inspect(bytes);
  }
  if (mode == "execute") {
    return run_execute(bytes);
  }
  print_usage();
  return 1;
}
