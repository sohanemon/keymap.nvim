#!/usr/bin/env bats
# Bats test file for keymap.nvim

@test "test runner exists and is executable" {
  run test -x "tests/run_tests.lua"
  [ "$status" -eq 0 ]
}

@test "run_tests.lua executes without errors" {
  run lua tests/run_tests.lua
  [ "$status" -eq 0 ]
}

@test "all tests pass" {
  run lua tests/run_tests.lua
  [[ "$output" == *"All tests passed!"* ]]
}

@test "correct number of tests executed" {
  run lua tests/run_tests.lua
  [[ "$output" == *"Total:  16"* ]]
}

@test "no tests failed" {
  run lua tests/run_tests.lua
  [[ "$output" == *"Failed: 0"* ]]
}
