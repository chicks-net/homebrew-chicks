# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Homebrew tap repository for distributing Christopher Hicks' software via [Homebrew](https://brew.sh/). Users can install packages from this tap with:

```bash
brew tap chicks-net/chicks
brew install chicks-net/chicks/<formula-name>
```

## Current Formulas

- **chicks-text-tools** - Text manipulation utilities (comify, ruler, roll, closefh)
  - Source: <https://github.com/chicks-net/chicks-home>
  - Depends on `lsof`
  - Formula file: `Formula/chicks-text-tools.rb`

- **chicks-git-tools** - Git/GitHub automation utilities (repos-summary, github_fix_https, apply-ruleset)
  - Source: <https://github.com/chicks-net/chicks-home>
  - Depends on `git`, `gh`, `jq`
  - Formula file: `Formula/chicks-git-tools.rb`
  - Includes GitHub ruleset templates in `share/chicks-git-tools/rulesets/`

- **chicks-monitoring-tools** - System and network monitoring utilities (watch_constate, watch_zk_conns, host_scanner, haproxy_stats, ip2smokeping)
  - Source: <https://github.com/chicks-net/chicks-home>
  - Runtime requirements: `netstat` (pre-installed on macOS), optional Perl modules (DateTime, Net::Telnet)
  - Formula file: `Formula/chicks-monitoring-tools.rb`

- **google-plus-posts-dumper** - Google+ Takeout to Markdown converter
  - Source: <https://github.com/chicks-net/google-plus-posts-dumper>
  - Depends on `rust` (build-time only)
  - Formula file: `Formula/google-plus-posts-dumper.rb`
  - First Rust-based formula in the tap

## Testing Formulas

The complete formula test suite uses `just` command runner:

```bash
just test-chicks-text-tools
```

This command:

1. Taps `chicks-net/chicks` if not already tapped
2. Copies local formula to tap directory (`$(brew --repository)/Library/Taps/chicks-net/homebrew-chicks`)
3. Installs formula from source: `brew install --build-from-source chicks-net/chicks/chicks-text-tools`
4. Verifies each tool works (comify, ruler, roll)
5. Runs formula test suite: `brew test chicks-text-tools`
6. Runs strict audit: `brew audit --strict --online chicks-text-tools`
7. Runs style check: `brew style Formula/*.rb`

To uninstall:

```bash
just uninstall-chicks-text-tools
```

For chicks-git-tools:

```bash
just test-chicks-git-tools
```

To uninstall:

```bash
just uninstall-chicks-git-tools
```

For chicks-monitoring-tools:

```bash
just test-chicks-monitoring-tools
```

To uninstall:

```bash
just uninstall-chicks-monitoring-tools
```

For google-plus-posts-dumper:

```bash
just test-google-plus-posts-dumper
```

**Note:** This is a Rust project and will take several minutes to compile from source.

To uninstall:

```bash
just uninstall-google-plus-posts-dumper
```

## Creating New Formula Files

When adding new Formula files to this tap:

1. Place them in a `Formula/` directory at the repository root
2. Formula files should be named using the formula name (e.g., `foo.rb` for a formula named "foo")
3. Use `brew create <URL>` as a starting point to generate a formula template
4. Test locally with the complete test suite (see Testing section)
5. Add a `just test-<formula-name>` recipe following the pattern in `justfile:16-72`

Key Formula conventions:

- Class names are CamelCase (e.g., `class FooBar < Formula`)
- Use `url` and `sha256` for source downloads
- Define `install` method for installation steps
- Add comprehensive `test do` block to verify installation

## Development Workflow

This repo uses `just` (command runner) for all development tasks. The workflow is command-line based using `just` and the GitHub CLI (`gh`).

### Standard development cycle

1. `just branch <name>` - Create a new feature branch (format: `$USER/YYYY-MM-DD-<name>`)
2. Make changes and commit (last commit message becomes PR title)
3. `just pr` - Create PR, push changes, and watch checks (waits 8s for GitHub API)
4. `just merge` - Squash merge PR, delete branch, return to main, and pull latest
5. `just sync` - Return to main branch and pull latest (escape hatch)

### Additional workflow commands

- `just` or `just list` - Show all available recipes
- `just prweb` - Open current PR in browser
- `just pr_checks` - Watch GitHub Actions checks and display Claude/Copilot reviews
- `just again` - Push changes, update PR description, and re-run checks
- `just pr_update` - Update PR description with current commit list
- `just release <version>` - Create a GitHub release with auto-generated notes
- `just release_age` - Check how long since last release
- `just compliance_check` - Run custom repo compliance checks
- `just shellcheck` - Run shellcheck on all bash scripts in just recipes

## GitHub Actions

Workflows run on PRs and pushes to main:

- **brew-formula-test** - Tests all formulas on ubuntu-latest and macos-latest
- **markdownlint** - Enforces markdown standards using `markdownlint-cli2`
- **checkov** - Security scanning for GitHub Actions
- **actionlint** - Lints GitHub Actions workflow files
- **auto-assign** - Automatically assigns issues/PRs to `chicks-net`
- **claude-code-review** - Claude AI review automation
- **claude** - Additional Claude integration

Run markdown linting locally: `markdownlint-cli2 **/*.md`

## Architecture Notes

- `.just/` directory contains modular just recipes imported by main justfile:
  - `gh-process.just` - Core git/GitHub workflow (branch, pr, merge, etc.)
  - `compliance.just` - Repository compliance checks
  - `shellcheck.just` - Shell script linting
  - `pr-hook.just` - Optional pre-PR hooks (currently not used)
- Main branch is `main` (referenced throughout gh-process.just)
- PR descriptions auto-generated from commit messages with "Done" and "Meta" sections
- The tap follows naming convention `homebrew-chicks` which makes it accessible as `chicks-net/chicks`
