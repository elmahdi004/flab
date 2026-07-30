#pragma once
#include <cstddef>
#include <cstdint>
#include <string>
#include <vector>

namespace atlas::io {

bool load_file(const std::string& path, std::vector<std::uint8_t>& out);
bool write_file(const std::string& path, const std::uint8_t* data, std::size_t size);

}
