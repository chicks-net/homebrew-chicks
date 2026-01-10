# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a Homebrew tap repository for distributing Christopher Hicks' software via [Homebrew](https://brew.sh/). Users can install packages from this tap with:

```bash
brew tap chicks-net/chicks
brew install chicks-net/chicks/<formula-name>
```

## Homebrew Tap Structure

Homebrew taps follow a specific directory structure:

- `Formula/*.rb` - Formula files for command-line tools and libraries
- `Casks/*.rb` - Cask files for macOS applications (GUI apps)

Currently this tap has no Formula or Cask files yet.

## Creating Formula Files

When adding new Formula files to this tap:

1. Place them in a `Formula/` directory at the repository root
2. Formula files should be named using the formula name (e.g., `foo.rb` for a formula named "foo")
3. Use `brew create <URL>` as a starting point to generate a formula template
4. Test locally with `brew install --build-from-source ./Formula/<name>.rb`
5. Use `brew audit --strict --online <formula>` to check for issues

Key Formula conventions:

- Class names are CamelCase (e.g., `class FooBar < Formula`)
- Use `url` and `sha256` for source downloads
- Define `install` method for installation steps
- Add `test do` block to verify installation

## Creating Cask Files

When adding Cask files for GUI applications:

1. Place them in a `Casks/` directory at the repository root
2. Cask files should be named using lowercase with hyphens (e.g., `foo-bar.rb`)
3. Use `brew create --cask <URL>` to generate a template
4. Test with `brew install --cask ./Casks/<name>.rb`
5. Audit with `brew audit --cask --strict --online <cask-name>`

## Development Workflow

This repo uses `just` (command runner) for all development tasks. The workflow is command-line based using `just` and the GitHub CLI (`gh`).

### Standard development cycle

1. `just branch <name>` - Create a new feature branch (format: `$USER/YYYY-MM-DD-<name>`)
2. Make changes and commit (last commit message becomes PR title)
3. `just pr` - Create PR, push changes, and watch checks (waits 8s for GitHub API)
4. `just merge` - Squash merge PR, delete branch, return to main, and pull latest
5. `just sync` - Return to main branch and pull latest (escape hatch)

### Additional commands

- `just` or `just list` - Show all available recipes
- `just prweb` - Open current PR in browser
- `just release <version>` - Create a GitHub release with auto-generated notes
- `just compliance_check` - Run custom repo compliance checks
- `just shellcheck` - Run shellcheck on all bash scripts in just recipes

## GitHub Actions

Workflows run on PRs and pushes to main:

- **markdownlint** - Enforces markdown standards using `markdownlint-cli2`
- **checkov** - Security scanning for GitHub Actions
- **actionlint** - Lints GitHub Actions workflow files
- **auto-assign** - Automatically assigns issues/PRs to `chicks-net`
- **claude-code-review** - Claude AI review automation
- **claude** - Additional Claude integration

Run markdown linting locally: `markdownlint-cli2 **/*.md`

## Important Notes

- This tap follows the naming convention `homebrew-chicks` which makes it accessible as `chicks-net/chicks`
- All git commands use standard git (no aliases required)
- The `.just` directory contains modular just recipes that can be copied to other projects
