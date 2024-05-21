#include <exception>
#include <fstream>
#include <iostream>
#include <iterator>
#include <string>

int main(int argc, const char *argv[]) {
  if (argc != 2) {
    std::cerr << "usage: ./assembler foo.asm\n";
    std::terminate();
  }

  auto file = std::ifstream(argv[1]);
  auto content = std::string(std::istreambuf_iterator<char>(file),
                             std::istreambuf_iterator<char>());
}
