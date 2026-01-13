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

# Test the chicks-git-tools formula
[group('Formula')]
test-chicks-git-tools:
	#!/usr/bin/env bash
	set -euo pipefail
	echo "{{BLUE}}Testing chicks-git-tools formula...{{NORMAL}}"

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
	if [[ ! Formula/chicks-git-tools.rb -ef "$TAP_DIR/Formula/chicks-git-tools.rb" ]]; then
		cp Formula/chicks-git-tools.rb "$TAP_DIR/Formula/"
		chmod 644 "$TAP_DIR/Formula/chicks-git-tools.rb"
		echo "{{GREEN}}Formula copied successfully{{NORMAL}}"
	else
		echo "{{GREEN}}Formula already in place (symlinked tap directory){{NORMAL}}"
	fi

	# Test installation
	echo "{{GREEN}}Installing formula from source...{{NORMAL}}"
	brew install --build-from-source chicks-net/chicks/chicks-git-tools

	# Verify tools work
	echo "{{GREEN}}Testing repos-summary...{{NORMAL}}"
	repos-summary 2>&1 | head -5 || true

	echo "{{GREEN}}Testing github_fix_https...{{NORMAL}}"
	github_fix_https 2>&1 | head -3 || true

	echo "{{GREEN}}Testing apply-ruleset...{{NORMAL}}"
	apply-ruleset 2>&1 || true

	# Verify rulesets are installed
	echo "{{GREEN}}Checking for bundled rulesets...{{NORMAL}}"
	PKGSHARE="$(brew --prefix)/share/chicks-git-tools"
	ls -la "$PKGSHARE/rulesets/"

	# Run formula tests
	echo "{{GREEN}}Running formula test suite...{{NORMAL}}"
	brew test chicks-git-tools

	# Run brew audit
	echo "{{GREEN}}Running brew audit...{{NORMAL}}"
	brew audit --strict --online chicks-git-tools

	# Run brew style
	echo "{{GREEN}}Running brew style...{{NORMAL}}"
	brew style Formula/*.rb

	echo "{{GREEN}}All tests passed!{{NORMAL}}"

# Uninstall the chicks-git-tools formula
[group('Formula')]
uninstall-chicks-git-tools:
	brew uninstall chicks-git-tools || echo "{{YELLOW}}Formula not installed{{NORMAL}}"

# Test the chicks-monitoring-tools formula
[group('Formula')]
test-chicks-monitoring-tools:
	#!/usr/bin/env bash
	set -euo pipefail
	echo "{{BLUE}}Testing chicks-monitoring-tools formula...{{NORMAL}}"

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
	if [[ ! Formula/chicks-monitoring-tools.rb -ef "$TAP_DIR/Formula/chicks-monitoring-tools.rb" ]]; then
		cp Formula/chicks-monitoring-tools.rb "$TAP_DIR/Formula/"
		chmod 644 "$TAP_DIR/Formula/chicks-monitoring-tools.rb"
		echo "{{GREEN}}Formula copied successfully{{NORMAL}}"
	else
		echo "{{GREEN}}Formula already in place (symlinked tap directory){{NORMAL}}"
	fi

	# Test installation
	echo "{{GREEN}}Installing formula from source...{{NORMAL}}"
	brew install --build-from-source chicks-net/chicks/chicks-monitoring-tools

	# Verify tools are installed (don't run monitoring tools as they loop)
	echo "{{GREEN}}Verifying watch_constate is installed...{{NORMAL}}"
	which watch_constate

	echo "{{GREEN}}Verifying watch_zk_conns is installed...{{NORMAL}}"
	which watch_zk_conns

	echo "{{GREEN}}Verifying graph_constate is installed...{{NORMAL}}"
	which graph_constate

	echo "{{GREEN}}Verifying host_scanner is installed...{{NORMAL}}"
	which host_scanner

	echo "{{GREEN}}Verifying haproxy_stats is installed...{{NORMAL}}"
	which haproxy_stats

	echo "{{GREEN}}Verifying ip2smokeping is installed...{{NORMAL}}"
	which ip2smokeping

	# Run formula tests
	echo "{{GREEN}}Running formula test suite...{{NORMAL}}"
	brew test chicks-monitoring-tools

	# Run brew audit
	echo "{{GREEN}}Running brew audit...{{NORMAL}}"
	brew audit --strict --online chicks-monitoring-tools

	# Run brew style
	echo "{{GREEN}}Running brew style...{{NORMAL}}"
	brew style Formula/*.rb

	echo "{{GREEN}}All tests passed!{{NORMAL}}"

# Uninstall the chicks-monitoring-tools formula
[group('Formula')]
uninstall-chicks-monitoring-tools:
	brew uninstall chicks-monitoring-tools || echo "{{YELLOW}}Formula not installed{{NORMAL}}"
