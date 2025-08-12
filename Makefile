# Makefile for typstwriter.nvim development

.PHONY: help test test-coverage test-watch lint format format-check check install-deps clean all ci install uninstall dev-setup docs version debug

# Default target
all: check test

# Show available targets with better formatting
help: ## Show this help message
	@echo "typstwriter.nvim Development Tasks"
	@echo "=================================="
	@echo ""
	@echo "Testing:"
	@echo "  test           Run integration tests (7 passing tests)"
	@echo "  test-all       Run all tests (some incomplete - for development)"
	@echo "  test-coverage  Run tests with coverage reporting"
	@echo "  test-watch     Run tests in watch mode"
	@echo ""
	@echo "Code Quality:"
	@echo "  lint           Run luacheck on source code"
	@echo "  format         Format code with stylua"
	@echo "  format-check   Check if code is properly formatted"
	@echo "  check          Run all quality checks (lint + format-check)"
	@echo ""
	@echo "Setup:"
	@echo "  install-deps   Install development dependencies"
	@echo "  clean          Clean generated files"
	@echo ""
	@echo "CI/CD:"
	@echo "  ci             Run full CI pipeline locally"
	@echo ""
	@echo "Plugin:"
	@echo "  install        Install plugin for local testing (manual management only)"
	@echo "  install-info   Show how to install with various plugin managers"
	@echo "  uninstall      Remove locally installed plugin"
	@echo ""
	@echo "Shortcuts: t=test, tc=test-coverage, l=lint, f=format, c=check"

# Lua environment setup
LUA_PATH_SETUP := eval $$(luarocks path)

# Testing targets
test: ## Run focused integration tests (passing tests)
	@echo "🧪 Running integration tests..."
	$(LUA_PATH_SETUP) && busted "spec/integration_spec.lua" --verbose

test-all: ## Run all tests (including incomplete ones)
	@echo "🧪 Running all tests..."
	$(LUA_PATH_SETUP) && busted "spec/*_spec.lua" --verbose

test-coverage: ## Run integration tests with coverage reporting
	@echo "📊 Running integration tests with coverage..."
	$(LUA_PATH_SETUP) && busted "spec/integration_spec.lua" --coverage --verbose
	@echo "📈 Generating coverage report..."
	$(LUA_PATH_SETUP) && luacov
	@echo "✅ Coverage report generated: luacov.report.out"

test-watch: ## Run tests in watch mode
	@echo "👀 Running tests in watch mode (Ctrl+C to stop)..."
	find lua/ spec/ -name "*.lua" | entr -c sh -c '$(LUA_PATH_SETUP) && busted "spec/integration_spec.lua" --verbose'

# Code quality targets
lint: ## Run luacheck linter
	@echo "🔍 Running luacheck..."
	luacheck lua/ spec/ --globals vim --no-unused-args

format: ## Format code with stylua
	@echo "🎨 Formatting code with stylua..."
	stylua lua/ spec/

format-check: ## Check if code is properly formatted
	@echo "🔍 Checking code formatting..."
	stylua --check lua/ spec/
	@echo "✅ Code formatting is correct"

check: lint format-check ## Run all quality checks
	@echo "✅ All quality checks passed!"

# Setup and maintenance
install-deps: ## Install development dependencies
	@echo "📦 Installing development dependencies..."
	@command -v luarocks >/dev/null 2>&1 || { echo "❌ Error: luarocks not found. Please install LuaRocks first."; exit 1; }
	luarocks install --local busted
	luarocks install --local luacov
	luarocks install --local luacheck
	@command -v stylua >/dev/null 2>&1 || echo "⚠️  Warning: stylua not found. Install from: https://github.com/JohnnyMorganz/StyLua"
	@echo "✅ Dependencies installed!"

clean: ## Clean generated files
	@echo "🧹 Cleaning generated files..."
	rm -f luacov.*.out
	rm -f *.log
	find . -name "*.tmp" -delete 2>/dev/null || true
	find . -name "*.bak" -delete 2>/dev/null || true
	@echo "✅ Clean complete!"

# CI pipeline
ci: clean check test-coverage ## Run full CI pipeline locally
	@echo "🚀 CI pipeline completed successfully!"

# Plugin installation for testing
NVIM_CONFIG_DIR := $(HOME)/.config/nvim
PLUGIN_DIR := $(NVIM_CONFIG_DIR)/pack/plugins/start/typstwriter.nvim

install: ## Install plugin for local testing (only if using manual plugin management)
	@echo "📦 Installing plugin for local testing..."
	@echo "⚠️  WARNING: This will install to $(PLUGIN_DIR)"
	@echo "⚠️  If you use a plugin manager (lazy.nvim, packer, etc.), use that instead!"
	@echo "⚠️  Run 'make install-info' to see plugin manager setup instructions."
	@read -p "Continue? [y/N]: " confirm && [ "$$confirm" = "y" ] || { echo "Installation cancelled."; exit 1; }
	@mkdir -p $(PLUGIN_DIR)
	@cp -r lua/ $(PLUGIN_DIR)/
	@cp -r doc/ $(PLUGIN_DIR)/ 2>/dev/null || true
	@cp plugin/ $(PLUGIN_DIR)/ 2>/dev/null || true
	@echo "✅ Plugin installed to: $(PLUGIN_DIR)"
	@echo "🔄 Restart Neovim to load the plugin"

install-info: ## Show installation instructions for various plugin managers
	@echo "📚 typstwriter.nvim Installation Guide"
	@echo "==========================================="
	@echo ""
	@echo "🚀 Recommended: Use your plugin manager!"
	@echo ""
	@echo "💻 For local development/testing:"
	@echo "  git clone $(PWD) ~/.local/share/nvim/site/pack/dev/start/typstwriter.nvim"
	@echo ""
	@echo "⚡ lazy.nvim:"
	@echo "  { 'gl1tchc0d3r/typstwriter.nvim', config = function() require('typstwriter').setup({}) end }"
	@echo ""
	@echo "📦 packer.nvim:"
	@echo "  use { 'gl1tchc0d3r/typstwriter.nvim', config = function() require('typstwriter').setup({}) end }"
	@echo ""
	@echo "🔌 vim-plug:"
	@echo "  Plug 'gl1tchc0d3r/typstwriter.nvim'"
	@echo "  -- Then add: require('typstwriter').setup({}) to your init.lua"
	@echo ""
	@echo "🗂️ Manual installation (not recommended):"
	@echo "  make install    # Use only if you don't use a plugin manager"
	@echo ""
	@echo "⚠️  The 'make install' target is only for users who manually manage plugins!"

uninstall: ## Remove locally installed plugin (only if installed via 'make install')
	@echo "🗑️  About to remove: $(PLUGIN_DIR)"
	@if [ ! -d "$(PLUGIN_DIR)" ]; then \
		echo "❌ Plugin directory not found. Nothing to uninstall."; \
		exit 1; \
	fi
	@echo "⚠️  WARNING: This will permanently delete $(PLUGIN_DIR)"
	@echo "⚠️  Only proceed if you installed via 'make install'!"
	@read -p "Are you sure? [y/N]: " confirm && [ "$$confirm" = "y" ] || { echo "Uninstall cancelled."; exit 1; }
	@rm -rf $(PLUGIN_DIR)
	@echo "✅ Plugin uninstalled"

# Development helpers
dev-setup: install-deps ## Set up development environment
	@echo "🛠️  Setting up development environment..."
	@mkdir -p examples/configs
	@echo "✅ Development setup complete!"

# Documentation
docs: ## Generate/check documentation
	@echo "📚 Checking documentation..."
	@command -v nvim >/dev/null 2>&1 && nvim --headless -c 'helptags doc/' -c 'quit' 2>/dev/null || echo "📝 Neovim not found, skipping doc generation"
	@echo "📖 Documentation available in README.md"

# Version and tool info
version: ## Show version information for development tools
	@echo "typstwriter.nvim development tools"
	@echo "===================================="
	@echo -n "busted: " && busted --version 2>/dev/null || echo "not installed"
	@echo -n "luacheck: " && luacheck --version 2>/dev/null || echo "not installed"
	@echo -n "stylua: " && stylua --version 2>/dev/null || echo "not installed"
	@echo -n "luacov: " && luacov -v 2>/dev/null || echo "not installed"

package-info: ## Show package information
	@echo "📦 Package: typstwriter.nvim"
	@echo "📋 Version: 1.0.0"
	@echo "👤 Author: gl1tchc0d3r"
	@echo "📄 License: MIT"
	@echo "📝 Description: A complete Typst writing system for Neovim"

# Quick shortcuts for common commands
t: test
tc: test-coverage
l: lint
f: format
c: check

# Debug info
debug: ## Show debug information
	@echo "🔧 Debug Information:"
	@echo "NVIM_CONFIG_DIR: $(NVIM_CONFIG_DIR)"
	@echo "PLUGIN_DIR: $(PLUGIN_DIR)"
	@echo "PWD: $(PWD)"
