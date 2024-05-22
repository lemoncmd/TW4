#include <array>
#include <bits/ranges_util.h>
#include <bitset>
#include <cassert>
#include <cctype>
#include <exception>
#include <fstream>
#include <iostream>
#include <iterator>
#include <sstream>
#include <string>
#include <string_view>
#include <unordered_map>
#include <variant>
#include <vector>

namespace tokenizer {

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

    if (cv.starts_with("//")) {
      auto pos = s.find_first_of("\n\r", i);
      if (pos == std::string::npos) {
        break;
      } else {
        i = pos;
        continue;
      }
    }

    if (cv.starts_with("/*")) {
      auto pos = cv.substr(2).find("*/");
      if (pos == std::string::npos) {
        std::cerr << "multi-line comment not closed" << std::endl;
        std::exit(1);
      } else {
        i = pos + 2;
        continue;
      }
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
        if (cv.size() != 4) {
          std::cerr << "imm must be 4 bit in binary format" << std::endl;
          std::exit(1);
        }
        tokens.push_back({TokenKind::imm, std::string(cv)});
        break;
      } else {
        auto len = pos - i;
        if (len != 4) {
          std::cerr << "imm must be 4 bit in binary format" << std::endl;
          std::exit(1);
        }
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
        tokens.push_back({TokenKind::label, std::string(cv.substr(0, len))});
        i += len;
        continue;
      }
    }

    std::cerr << "unexpected character: " << c << std::endl;
    std::exit(1);
  }
  return tokens;
}

} // namespace tokenizer

namespace parser {
enum class Register { a, b };
using Source = std::variant<Register, std::string>;

struct Mov {
  Register dst;
  Source src;
};
struct Add {
  Register dst;
  std::string src;
};
struct In {
  Register dst;
};
struct Out {
  Source src;
};
struct Jnc {
  std::string dst;
};
struct Jmp {
  std::string dst;
};
struct Swap {};
struct Swi {};
struct Iret {};
struct Imsk {
  std::string mask;
};
using Instruction =
    std::variant<Mov, Add, In, Out, Jnc, Jmp, Swap, Swi, Iret, Imsk>;

struct Result {
  std::array<std::vector<Instruction>, 4> instructions;
  std::array<std::unordered_map<std::string, int>, 4> labels;
};
Result parse(std::vector<tokenizer::Token> &tokens) {
  Result result{};
  enum class Section { user, swi, exception, irq };
  using tokenizer::TokenKind;
  auto section = Section::user;

  for (int i = 0; i < tokens.size();) {
    auto expect = [&](auto token_process) {
      if (i >= tokens.size()) {
        std::cerr << "reached end while reading instruction";
        std::exit(1);
      }
      token_process();
      i++;
    };
    auto expect_read = [&](auto token_process) {
      if (i >= tokens.size()) {
        std::cerr << "reached end while reading instruction";
        std::exit(1);
      }
      auto ret = token_process();
      i++;
      return ret;
    };
    auto token_error = [&](const char *expected) __attribute__((noreturn)) {
      std::cerr << "unexpected token `" << tokens[i].value << "`, expected "
                << expected << std::endl;
      std::exit(1);
    };
    auto read_register = [&]() {
      switch (tokens[i].kind) {
      case TokenKind::a:
        return Register::a;
      case TokenKind::b:
        return Register::b;
      default:
        token_error("register");
      }
    };
    auto read_imm = [&]() {
      if (tokens[i].kind != TokenKind::imm) {
        token_error("imm");
      }
      return tokens[i].value;
    };
    auto read_source = [&]() {
      switch (tokens[i].kind) {
      case TokenKind::a:
        return Source(Register::a);
      case TokenKind::b:
        return Source(Register::b);
      case TokenKind::imm:
        return Source(tokens[i].value);
      default:
        token_error("register or imm");
      }
    };
    auto read_label = [&]() {
      if (tokens[i].kind != TokenKind::label) {
        token_error("label");
      }
      return tokens[i].value;
    };
    auto read_comma = [&]() {
      if (tokens[i].kind != TokenKind::comma) {
        token_error(",");
      }
    };

    switch (tokens[i].kind) {
    case TokenKind::section:
      i++;
      expect([&]() {
        switch (tokens[i].kind) {
        case TokenKind::user:
          section = Section::user;
          break;
        case TokenKind::swi:
          section = Section::swi;
          break;
        case TokenKind::exception:
          section = Section::exception;
          break;
        case TokenKind::irq:
          section = Section::irq;
          break;
        default:
          token_error("section name");
        }
      });
      break;

    case TokenKind::mov: {
      i++;
      auto dst = expect_read(read_register);
      expect(read_comma);
      auto src = expect_read(read_source);
      if (auto src_reg = std::get_if<Register>(&src)) {
        if (*src_reg == dst) {
          std::cerr << "source and dest must be different for mov" << std::endl;
          std::exit(1);
        }
      }
      result.instructions[int(section)].push_back(Mov{dst, src});
      break;
    }

    case TokenKind::add: {
      i++;
      auto dst = expect_read(read_register);
      expect(read_comma);
      auto src = expect_read(read_imm);
      result.instructions[int(section)].push_back(Add{dst, src});
      break;
    }

    case TokenKind::in: {
      i++;
      auto dst = expect_read(read_register);
      result.instructions[int(section)].push_back(In{dst});
      break;
    }

    case TokenKind::out: {
      i++;
      auto src = expect_read([&]() {
        switch (tokens[i].kind) {
        case TokenKind::b:
          return Source(Register::b);
        case TokenKind::imm:
          return Source(tokens[i].value);
        default:
          token_error("b or imm");
        }
      });
      result.instructions[int(section)].push_back(Out{src});
      break;
    }

    case TokenKind::jnc: {
      i++;
      auto dst = expect_read(read_label);
      result.instructions[int(section)].push_back(Jnc{dst});
      break;
    }

    case TokenKind::jmp: {
      i++;
      auto dst = expect_read(read_label);
      result.instructions[int(section)].push_back(Jmp{dst});
      break;
    }

    case TokenKind::swap: {
      if (section == Section::user) {
        std::cerr << "cannot use swap in user mode" << std::endl;
        std::exit(1);
      }
      i++;
      result.instructions[int(section)].push_back(Swap{});
      break;
    }

    case TokenKind::swi: {
      if (section != Section::user) {
        std::cerr << "cannot use swi in privilege mode" << std::endl;
        std::exit(1);
      }
      i++;
      result.instructions[int(section)].push_back(Swi{});
      break;
    }

    case TokenKind::iret: {
      if (section == Section::user) {
        std::cerr << "cannot use iret in user mode" << std::endl;
        std::exit(1);
      }
      i++;
      result.instructions[int(section)].push_back(Iret{});
      break;
    }

    case TokenKind::imsk: {
      i++;
      auto mask = expect_read(read_imm);
      result.instructions[int(section)].push_back(Imsk{mask});
      break;
    }

    case TokenKind::label: {
      auto label = tokens[i].value;
      i++;
      expect([&]() {
        if (tokens[i].kind != TokenKind::colon) {
          token_error(":");
        }
      });
      result.labels[int(section)].emplace(
          label, result.instructions[int(section)].size());
      break;
    }

    default:
      token_error("instruction");
    }
  }
  for (int i; i < 4; i++) {
    const char *section_name[] = {"user", "swi", "exception", "irq"};
    if (result.instructions[i].size() > 16) {
      std::cerr << "too many instructions in section" << section_name[i]
                << std::endl;
      std::exit(1);
    }
  }
  return result;
}
} // namespace parser

namespace generator {
[[noreturn]] void unreachable() { assert(false); }
std::string generate(parser::Result result) {
  std::ostringstream oss;
  for (int i = 0; i < 4; i++) {
    using namespace std::literals::string_literals;
    struct Visitor {
      std::unordered_map<std::string, int> labels;
      auto operator()(parser::Mov mov) {
        struct SourceVisitor {
          parser::Register dst;
          auto operator()(parser::Register) {
            switch (dst) {
            case parser::Register::a:
              return "00010000"s;
            case parser::Register::b:
              return "01000000"s;
            default:
              unreachable();
            }
          }
          auto operator()(std::string src) {
            switch (dst) {
            case parser::Register::a:
              return "0011"s + src;
            case parser::Register::b:
              return "0111"s + src;
            default:
              unreachable();
            }
          }
        };
        return std::visit(SourceVisitor{mov.dst}, mov.src);
      }
      auto operator()(parser::Add add) {
        switch (add.dst) {
        case parser::Register::a:
          return "0000"s + add.src;
        case parser::Register::b:
          return "0101"s + add.src;
        default:
          unreachable();
        }
      }
      auto operator()(parser::In in) {
        switch (in.dst) {
        case parser::Register::a:
          return "00100000"s;
        case parser::Register::b:
          return "01100000"s;
        default:
          unreachable();
        }
      }
      auto operator()(parser::Out out) {
        struct SourceVisitor {
          auto operator()(parser::Register) { return "10010000"s; }
          auto operator()(std::string src) { return "1011"s + src; }
        };
        return std::visit(SourceVisitor{}, out.src);
      }
      auto operator()(parser::Jnc jnc) {
        return "1110"s + std::bitset<4>(labels[jnc.dst]).to_string();
      }
      auto operator()(parser::Jmp jmp) {
        return "1111"s + std::bitset<4>(labels[jmp.dst]).to_string();
      }
      auto operator()(parser::Swap) { return "11000000"s; }
      auto operator()(parser::Swi) { return "11010000"s; }
      auto operator()(parser::Iret) { return "11010000"s; }
      auto operator()(parser::Imsk imsk) { return "1010" + imsk.mask; }
    };

    while (result.instructions[i].size() != 16) {
      result.instructions[i].push_back(
          parser::Add{parser::Register::a, "0000"});
    }
    for (auto instruction : result.instructions[i]) {
      oss << std::visit(Visitor{result.labels[i]}, instruction) << "\n";
    }
  }
  return oss.str();
}
} // namespace generator

int main(int argc, const char *argv[]) {
  if (argc != 2) {
    std::cerr << "usage: ./assembler foo.asm" << std::endl;
    std::exit(1);
  }

  auto file = std::ifstream(argv[1]);
  auto content = std::string(std::istreambuf_iterator<char>(file),
                             std::istreambuf_iterator<char>());

  auto tokens = tokenizer::tokenize(content);

  auto parse_result = parser::parse(tokens);

  auto binary = generator::generate(parse_result);

  std::cout << binary;
}
