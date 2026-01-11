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
	BREW_REPO="$(brew --repository)"
	TAP_DIR="$BREW_REPO/Library/Taps/chicks-net/homebrew-chicks"
	if [[ ! -d "$TAP_DIR" ]]; then
		echo "{{RED}}Error: Tap directory not found at $TAP_DIR{{NORMAL}}"
		exit 1
	fi
	mkdir -p "$TAP_DIR/Formula"

	# Only copy if source and destination are different files
	if [[ ! Formula/chicks-text-tools.rb -ef "$TAP_DIR/Formula/chicks-text-tools.rb" ]]; then
		cp Formula/chicks-text-tools.rb "$TAP_DIR/Formula/"
		chmod 644 "$TAP_DIR/Formula/chicks-text-tools.rb"
		echo "{{GREEN}}Formula copied successfully{{NORMAL}}"
	else
		echo "{{GREEN}}Formula already in place (symlinked tap directory){{NORMAL}}"
	fi

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

	# Run brew audit
	echo "{{GREEN}}Running brew audit...{{NORMAL}}"
	brew audit --strict --online chicks-text-tools

	# Run brew style
	echo "{{GREEN}}Running brew style...{{NORMAL}}"
	brew style Formula/*.rb

	echo "{{GREEN}}All tests passed!{{NORMAL}}"

# Uninstall the chicks-text-tools formula
[group('Formula')]
uninstall-chicks-text-tools:
	brew uninstall chicks-text-tools || echo "{{YELLOW}}Formula not installed{{NORMAL}}"
