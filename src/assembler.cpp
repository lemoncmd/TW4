#include <array>
#include <bits/ranges_util.h>
#include <cctype>
#include <exception>
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
  for (int i = 0; i < s.length();) {
    char c = s[i];
    auto cv = s.substr(i);

    if (std::string(" \n\r\t").find(c) != std::string::npos) {
      i++;
      continue;
    }

    if (c == ':') {
      tokens.push_back({TokenKind::colon, ":"});
      i++;
      continue;
    }

    if (c == ',') {
      tokens.push_back({TokenKind::comma, ","});
      i++;
      continue;
    }

    if (cv.starts_with(".section")) {
      tokens.push_back({TokenKind::section, ".section"});
      i += 8;
      continue;
    }

    auto cond = [&](std::string_view needle) {
      auto after = i + needle.length();
      return cv.starts_with(needle) &&
             (after == s.length() || !std::isalpha(s[after]));
    };

    auto keywords = std::array<std::pair<std::string, TokenKind>, 15>{
        std::pair("user", TokenKind::user),
        std::pair("swi", TokenKind::swi),
        std::pair("exception", TokenKind::exception),
        std::pair("irq", TokenKind::irq),
        std::pair("add", TokenKind::add),
        std::pair("mov", TokenKind::mov),
        std::pair("in", TokenKind::in),
        std::pair("out", TokenKind::out),
        std::pair("imsk", TokenKind::imsk),
        std::pair("swap", TokenKind::swap),
        std::pair("iret", TokenKind::iret),
        std::pair("jnc", TokenKind::jnc),
        std::pair("jmp", TokenKind::jmp),
        std::pair("a", TokenKind::a),
        std::pair("b", TokenKind::b),
    };

    bool found = false;

    for (auto [keyword, kind] : keywords) {
      if (cond(keyword)) {
        tokens.push_back({kind, keyword});
        i += keyword.length();
        found = true;
        break;
      }
    }

    if (found) {
      continue;
    }

    if (c == '0' || c == '1') {
      auto pos = s.find_first_not_of("01", i);
      if (pos == std::string::npos) {
        tokens.push_back({TokenKind::imm, std::string(cv)});
        break;
      } else {
        auto len = pos - i;
        tokens.push_back({TokenKind::imm, std::string(cv.substr(0, len))});
        i += len;
        continue;
      }
    }

    if (std::isalpha(c)) {
      auto pos = std::ranges::find_if_not(
          cv, [](char c) { return std::isalnum(c) || c == '_'; });
      if (pos == s.end()) {
        tokens.push_back({TokenKind::imm, std::string(cv)});
        break;
      } else {
        auto len = std::distance(cv.begin(), pos);
        tokens.push_back({TokenKind::imm, std::string(cv.substr(0, len))});
        i += len;
        continue;
      }
    }

    std::cerr << "unexpected character: " << c << std::endl;
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
