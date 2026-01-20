.PHONY: test test-lua lint format

test: test-lua

test-lua:
	@echo "Running Lua tests..."
	@lua tests/run_tests.lua

lint:
	@echo "Linting Lua files..."
	@luacheck lua/ tests/ 2>/dev/null || echo "luacheck not installed"

format:
	@echo "Formatting Lua files..."
	@stylua lua/ tests/ 2>/dev/null || echo "stylua not installed"
