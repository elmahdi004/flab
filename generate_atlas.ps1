$root = 'C:\Users\user\Desktop\fuzzlab'
Set-Location $root
$path = Join-Path $root 'src\atlas\atlas.cpp'
$lines = [System.Collections.Generic.List[string]]::new()
$pre = @'
#include "atlas.h"
#include <algorithm>
#include <array>
#include <cstdint>
#include <cstring>
#include <limits>
#include <string>
#include <vector>

namespace atlas {
namespace {
struct Slice {
  const std::uint8_t* data;
  std::size_t size;
};

struct Section {
  std::uint32_t kind;
  std::uint32_t flags;
  std::uint64_t offset;
  std::uint64_t length;
};

struct Transition {
  std::uint16_t opcode;
  std::uint16_t mode;
  std::uint32_t left;
  std::uint32_t right;
};

struct Program {
  std::vector<Section> sections;
  std::vector<std::string> strings;
  std::vector<std::uint32_t> instructions;
  std::uint64_t fingerprint = 0;
};

static std::uint64_t rotl(std::uint64_t value, unsigned amount) {
  amount &= 63U;
  return (value << amount) | (value >> ((64U - amount) & 63U));
}

static std::uint64_t mix(std::uint64_t state, std::uint64_t value) {
  state ^= value + 0x9e3779b97f4a7c15ULL + (state << 6) + (state >> 2);
  state = rotl(state, static_cast<unsigned>(value & 31U) + 1U);
  state *= 0xd6e8feb86659fd93ULL;
  state ^= state >> 29;
  state *= 0xa5b85c5e198ed849ULL;
  return state ^ (state >> 32);
}

static bool read_u8(Slice input, std::size_t& offset, std::uint8_t& out) {
  if (offset >= input.size) {
    return false;
  }
  out = input.data[offset++];
  return true;
}

static bool read_u32(Slice input, std::size_t& offset, std::uint32_t& out) {
  if (offset + 4 > input.size) {
    return false;
  }
  std::uint32_t value = 0;
  value |= static_cast<std::uint32_t>(input.data[offset + 0]) << 0;
  value |= static_cast<std::uint32_t>(input.data[offset + 1]) << 8;
  value |= static_cast<std::uint32_t>(input.data[offset + 2]) << 16;
  value |= static_cast<std::uint32_t>(input.data[offset + 3]) << 24;
  offset += 4;
  out = value;
  return true;
}

static bool read_u64(Slice input, std::size_t& offset, std::uint64_t& out) {
  if (offset + 8 > input.size) {
    return false;
  }
  std::uint64_t value = 0;
  for (int i = 0; i < 8; ++i) {
    value |= static_cast<std::uint64_t>(input.data[offset + static_cast<std::size_t>(i)]) << (8 * i);
  }
  offset += 8;
  out = value;
  return true;
}

static bool read_varint(Slice input, std::size_t& offset, std::uint64_t& out) {
  std::uint64_t value = 0;
  unsigned shift = 0;
  for (unsigned i = 0; i < 10; ++i) {
    std::uint8_t byte = 0;
    if (!read_u8(input, offset, byte)) {
      return false;
    }
    value |= static_cast<std::uint64_t>(byte & 0x7fU) << shift;
    if ((byte & 0x80U) == 0) {
      out = value;
      return true;
    }
    shift += 7;
  }
  return false;
}

static bool read_string(Slice input, std::size_t& offset, std::string& out) {
  std::uint64_t length = 0;
  if (!read_varint(input, offset, length)) {
    return false;
  }
  if (length > input.size - offset) {
    return false;
  }
  out.assign(reinterpret_cast<const char*>(input.data + offset), static_cast<std::size_t>(length));
  offset += static_cast<std::size_t>(length);
  return true;
}

static std::uint64_t fold_bytes(Slice input) {
  std::uint64_t state = 0x1234abcd6789ef01ULL;
  for (std::size_t i = 0; i < input.size; ++i) {
    state = mix(state, static_cast<std::uint64_t>(input.data[i]) + (static_cast<std::uint64_t>(i) << 8));
  }
  return state;
}

static std::uint64_t transition_key(std::uint32_t opcode, std::uint32_t mode, std::uint32_t left, std::uint32_t right) {
  std::uint64_t state = opcode;
  state = mix(state, mode);
  state = mix(state, left);
  state = mix(state, right);
  return state;
}

static const Transition kTransitions[] = {
'@
$lines.AddRange(($pre.TrimEnd("`r", "`n") -split "`r?`n"))
for ($i = 0; $i -lt 14000; ++$i) {
  $opcode = $i % 256
  $mode = ($i * 3) % 11
  $left = ($i * 17 + 5) % 257
  $right = ($i * 29 + 13) % 263
  $lines.Add(("  {{{0}u, {1}u, {2}u, {3}u}}," -f $opcode, $mode, $left, $right))
}
$post = @'
};

static constexpr std::size_t kTransitionCount = sizeof(kTransitions) / sizeof(kTransitions[0]);

static bool parse_sections(Slice input, std::size_t& offset, Program& program, std::uint32_t count) {
  program.sections.reserve(count);
  for (std::uint32_t i = 0; i < count; ++i) {
    Section section;
    std::uint32_t kind = 0;
    std::uint32_t flags = 0;
    std::uint64_t section_offset = 0;
    std::uint64_t section_length = 0;
    if (!read_u32(input, offset, kind)) {
      return false;
    }
    if (!read_u32(input, offset, flags)) {
      return false;
    }
    if (!read_u64(input, offset, section_offset)) {
      return false;
    }
    if (!read_u64(input, offset, section_length)) {
      return false;
    }
    section.kind = kind;
    section.flags = flags;
    section.offset = section_offset;
    section.length = section_length;
    program.sections.push_back(section);
  }
  return true;
}

static bool parse_strings(Slice input, std::size_t& offset, Program& program, std::uint32_t count) {
  program.strings.reserve(count);
  for (std::uint32_t i = 0; i < count; ++i) {
    std::string value;
    if (!read_string(input, offset, value)) {
      return false;
    }
    program.strings.push_back(std::move(value));
  }
  return true;
}

static bool parse_instructions(Slice input, std::size_t& offset, Program& program, std::uint32_t count) {
  program.instructions.reserve(count);
  for (std::uint32_t i = 0; i < count; ++i) {
    std::uint32_t opcode = 0;
    if (!read_u32(input, offset, opcode)) {
      return false;
    }
    program.instructions.push_back(opcode);
  }
  return true;
}

static std::uint64_t resolve_reference(const Program& program, std::size_t index, std::uint32_t kind) {
  if (program.sections.empty()) {
    return 0;
  }
  std::size_t pivot = index % program.sections.size();
  if (kind == 3 && pivot == 0 && program.sections.size() > 1) {
    return program.sections[pivot - 1].offset;
  }
  const Section& current = program.sections[pivot];
  std::uint64_t state = current.offset ^ current.length;
  state = mix(state, current.kind);
  state = mix(state, current.flags);
  return state;
}

static std::uint64_t analyze_transition_chain(const Program& program) {
  std::uint64_t state = program.fingerprint;
  for (std::size_t i = 0; i < program.sections.size(); ++i) {
    const Section& section = program.sections[i];
    std::size_t index = static_cast<std::size_t>(transition_key(section.kind, section.flags, static_cast<std::uint32_t>(section.offset), static_cast<std::uint32_t>(section.length)) % kTransitionCount);
    const Transition& t = kTransitions[index];
    state = mix(state, t.opcode);
    state = mix(state, t.mode);
    state = mix(state, t.left);
    state = mix(state, t.right);
    state = mix(state, resolve_reference(program, i, t.mode));
  }
  return state;
}

static std::uint64_t validate_program(const Program& program) {
  std::uint64_t state = 0x6d2b79f5aa0f9b4dULL;
  for (std::size_t i = 0; i < program.strings.size(); ++i) {
    state = mix(state, program.strings[i].size());
    for (unsigned char ch : program.strings[i]) {
      state = mix(state, ch + static_cast<std::uint64_t>(i));
    }
  }
  for (std::size_t i = 0; i < program.instructions.size(); ++i) {
    state = mix(state, program.instructions[i]);
  }
  return state;
}

static bool parse_document(Slice input, Program& program) {
  std::size_t offset = 0;
  std::uint32_t magic = 0;
  if (!read_u32(input, offset, magic)) {
    return false;
  }
  if (magic != 0x304c5441U) {
    return false;
  }
  std::uint32_t section_count = 0;
  std::uint32_t string_count = 0;
  std::uint32_t instruction_count = 0;
  if (!read_u32(input, offset, section_count)) {
    return false;
  }
  if (!read_u32(input, offset, string_count)) {
    return false;
  }
  if (!read_u32(input, offset, instruction_count)) {
    return false;
  }
  if (!parse_sections(input, offset, program, section_count)) {
    return false;
  }
  if (!parse_strings(input, offset, program, string_count)) {
    return false;
  }
  if (!parse_instructions(input, offset, program, instruction_count)) {
    return false;
  }
  program.fingerprint = fold_bytes(input);
  return true;
}

static std::uint64_t optimize_program(Program& program) {
  std::uint64_t state = program.fingerprint;
  for (std::size_t i = 0; i < program.sections.size(); ++i) {
    Section& section = program.sections[i];
    state = mix(state, section.kind + section.flags);
    if ((section.flags & 1U) != 0U) {
      section.offset ^= static_cast<std::uint64_t>(section.kind + 1U) << 4;
    } else {
      section.length += static_cast<std::uint64_t>(section.flags & 7U);
    }
    if ((section.flags & 2U) != 0U && !program.sections.empty()) {
      std::size_t pivot = static_cast<std::size_t>((section.kind + i) % program.sections.size());
      section.offset += program.sections[pivot].offset & 0xffU;
    }
  }
  return state;
}

static std::uint32_t execute_program(Program& program) {
  std::uint64_t state = validate_program(program);
  state = mix(state, optimize_program(program));
  state = mix(state, analyze_transition_chain(program));
  std::uint32_t total = static_cast<std::uint32_t>(state ^ (state >> 32));
  for (std::size_t i = 0; i < program.instructions.size(); ++i) {
    std::uint32_t opcode = program.instructions[i];
    const Transition& t = kTransitions[opcode % kTransitionCount];
    total ^= static_cast<std::uint32_t>(mix(total, t.opcode + t.mode + t.left + t.right));
    total = static_cast<std::uint32_t>(rotl(total, (opcode & 15U) + 1U));
    if ((opcode & 3U) == 0U && !program.sections.empty()) {
      std::size_t pivot = static_cast<std::size_t>(opcode % program.sections.size());
      total ^= static_cast<std::uint32_t>(resolve_reference(program, pivot, t.mode));
    }
  }
  return total;
}

static DocumentInfo inspect_impl(const std::uint8_t* data, std::size_t size) {
  Slice input{data, size};
  Program program;
  DocumentInfo info{0, 0, 0, 0};
  if (!parse_document(input, program)) {
    return info;
  }
  info.fingerprint = execute_program(program);
  info.section_count = program.sections.size();
  info.instruction_count = program.instructions.size();
  info.string_count = program.strings.size();
  return info;
}
}

DocumentInfo inspect(const std::uint8_t* data, std::size_t size) {
  return inspect_impl(data, size);
}

std::uint32_t execute(const std::uint8_t* data, std::size_t size) {
  Slice input{data, size};
  Program program;
  if (!parse_document(input, program)) {
    return 0;
  }
  return execute_program(program) ^ static_cast<std::uint32_t>(program.fingerprint);
}
}
'@
$lines.AddRange(($post.TrimStart("`r", "`n") -split "`r?`n"))
Set-Content -Encoding ascii -Path $path -Value $lines
