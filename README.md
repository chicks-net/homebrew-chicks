# homebrew-chicks

![GitHub Issues](https://img.shields.io/github/issues/chicks-net/homebrew-chicks)
![GitHub Pull Requests](https://img.shields.io/github/issues-pr/chicks-net/homebrew-chicks)
![GitHub License](https://img.shields.io/github/license/chicks-net/homebrew-chicks)
![GitHub watchers](https://img.shields.io/github/watchers/chicks-net/homebrew-chicks)

Install some of my software with [Homebrew](https://brew.sh/).

![Superfluous AI image, thanks to Nano Banana and Galaxy.AI](docs/flamingo-brewery-tap-with-chicks.jpg)

## Installation

Install the tap:

```bash
brew tap chicks-net/chicks
```

## Available Formulas

Here are a couple of sets of tools that you might find interesting.
More formula
[are planned](https://github.com/chicks-net/homebrew-chicks/issues).
Feedback is welcomed.

### chicks-git-tools

Git and GitHub automation utilities:

- **repos-summary** - Comprehensive repository health checker
- **github_fix_https** - Convert HTTPS repo clones to SSH
- **apply-ruleset** - Apply GitHub rulesets via API

Installation:

```bash
brew install chicks-net/chicks/chicks-git-tools
```

Usage with bundled rulesets:

```bash
# Find installed rulesets
RULESETS="$(brew --prefix)/share/chicks-git-tools/rulesets"

# Apply default linear history ruleset
apply-ruleset "$RULESETS/default-linear.json" my-repo

# Apply pull request requirement ruleset
apply-ruleset "$RULESETS/require-pr.json" my-repo
```

**Note:** `apply-ruleset` works on public repos (requires GitHub Pro for private repos).

### chicks-text-tools

Text manipulation utilities:

- **comify** - Convert newline-separated values to comma-separated
- **ruler** - Display character ruler for counting columns
- **roll** - D&D dice roller (supports notation like 2d6, d20)
- **closefh** - Close file descriptors (requires lsof)

Installation:

```bash
brew install chicks-net/chicks/chicks-text-tools
```

## Contributing

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Contributing Guide](.github/CONTRIBUTING.md) includes a step-by-step guide to our
  [development process](.github/CONTRIBUTING.md#development-process).

## Support & Security

- [Getting Support](.github/SUPPORT.md)
- [Security Policy](.github/SECURITY.md)
