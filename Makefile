.PHONY: test test-lua test-all lint lint-lua

test: test-all

test-lua:
	@echo "Running Lua tests with busted..."
	@busted --verbose --lua=$(LUA_VERSION) tests/

test-all: test-lua

lint:
	@echo "Linting Lua files..."
	@luacheck lua/ tests/

lint-lua:
	@echo "Linting Lua files..."
	@luacheck lua/ tests/

format:
	@echo "Formatting Lua files..."
	@stylua lua/ tests/

install-deps:
	@echo "Installing dependencies..."
	@luarocks install busted
	@luarocks install luacheck
	@luarocks install stylua
