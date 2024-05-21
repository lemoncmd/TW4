#include <exception>
#include <format>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>
#include <string_view>
#include <vector>

enum class TokenKind {
  section,
  user,
  swi,
  exception,
  irq,
  add,
  mov,
  in,
  out,
  imsk,
  swap,
  iret,
  jnc,
  jmp,
  a,
  b,
  colon,
  comma,
  label,
  imm
};

struct Token {
  TokenKind kind;
  std::string value;
};

std::vector<Token> tokenize(std::string_view s) {
  std::vector<Token> tokens{};
  for (int i; i < s.length();) {
    if (std::string(" \n\r\t").find(s[i]) == std::string::npos) {
      i++;
      continue;
    }
    std::cerr << std::format("unexpected character: {}", s[i]);
    std::terminate();
  }
  return tokens;
}

int main(int argc, const char *argv[]) {
  if (argc != 2) {
    std::cerr << "usage: ./assembler foo.asm\n";
    std::terminate();
  }

  auto file = std::ifstream(argv[1]);
  auto content = std::string(std::istreambuf_iterator<char>(file),
                             std::istreambuf_iterator<char>());

  auto tokens = tokenize(content);
}
