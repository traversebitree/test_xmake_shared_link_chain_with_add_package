// Copyright (c) 2024 Xiangyu Kong
//
// This software is released under the MIT License.
// https://opensource.org/licenses/MIT

#include <dylibsrc.hpp>
#include <fmt/core.h>

void print_calc_plus_ab(int a, int b) {
  fmt::print("Result of {} + {} is {}.n", a, b, a + b);
}