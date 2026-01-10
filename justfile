# project justfile

import? '.just/compliance.just'
import? '.just/gh-process.just'
import? '.just/pr-hook.just'
import? '.just/shellcheck.just'

# list recipes (default works without naming it)
[group('example')]
list:
	just --list
	@echo "{{GREEN}}Your justfile is waiting for more scripts and snippets{{NORMAL}}"

# Test the chicks-text-tools formula
[group('Formula')]
test-chicks-text-tools:
	#!/usr/bin/env bash
	set -euo pipefail
	echo "{{BLUE}}Testing chicks-text-tools formula...{{NORMAL}}"

	# Ensure tap exists
	if ! brew tap | grep -q "chicks-net/chicks"; then
		echo "{{GREEN}}Tapping chicks-net/chicks...{{NORMAL}}"
		brew tap chicks-net/chicks
	fi

	# Copy local formula to tapped repository for testing
	echo "{{GREEN}}Copying formula to tap directory...{{NORMAL}}"
	TAP_DIR="/opt/homebrew/Library/Taps/chicks-net/homebrew-chicks"
	mkdir -p "$TAP_DIR/Formula"
	cp Formula/chicks-text-tools.rb "$TAP_DIR/Formula/"

	# Test installation
	echo "{{GREEN}}Installing formula from source...{{NORMAL}}"
	brew install --build-from-source chicks-net/chicks/chicks-text-tools

	# Verify tools work
	echo "{{GREEN}}Testing comify...{{NORMAL}}"
	echo -e "a\nb\nc" | comify

	echo "{{GREEN}}Testing ruler...{{NORMAL}}"
	ruler

	echo "{{GREEN}}Testing roll...{{NORMAL}}"
	roll d20

	# Run formula tests
	echo "{{GREEN}}Running formula test suite...{{NORMAL}}"
	brew test chicks-text-tools

	echo "{{GREEN}}All tests passed!{{NORMAL}}"

# Uninstall the chicks-text-tools formula
[group('Formula')]
uninstall-chicks-text-tools:
	brew uninstall chicks-text-tools || echo "{{YELLOW}}Formula not installed{{NORMAL}}"
