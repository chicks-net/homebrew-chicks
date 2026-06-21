# homebrew-chicks

[![OpenSSF Scorecard](https://api.scorecard.dev/projects/github.com/chicks-net/homebrew-chicks/badge)](https://scorecard.dev/viewer/?uri=github.com/chicks-net/homebrew-chicks)
![GitHub Issues](https://img.shields.io/github/issues/chicks-net/homebrew-chicks)
![GitHub Pull Requests](https://img.shields.io/github/issues-pr/chicks-net/homebrew-chicks)
![GitHub License](https://img.shields.io/github/license/chicks-net/homebrew-chicks)
![GitHub watchers](https://img.shields.io/github/watchers/chicks-net/homebrew-chicks)
![GitHub commits since latest release](https://img.shields.io/github/commits-since/chicks-net/homebrew-chicks/latest)

Install some of my software with [Homebrew](https://brew.sh/).

![Superfluous AI image, thanks to Nano Banana and Galaxy.AI](docs/flamingo-brewery-tap-with-chicks.jpg)

## Installation

Install the tap:

```bash
brew tap chicks-net/chicks
```

> **Note:** Homebrew is introducing [tap trust](https://docs.brew.sh/Tap-Trust) as a security measure.
> Starting in Homebrew 6.0.0 (or 5.2.0, whichever comes first), non-official taps will require explicit trust.
> To trust this tap now, run:
>
> ```bash
> brew trust --tap chicks-net/chicks
> ```
>
> Or set `HOMEBREW_REQUIRE_TAP_TRUST=1` to opt into the new behavior early.
> See [Homebrew/brew#22635](https://github.com/Homebrew/brew/pull/22635) for the Brewfile trust documentation
> and [Homebrew/brew#22652](https://github.com/Homebrew/brew/pull/22652) for ongoing trust handling improvements.

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

### chicks-monitoring-tools

System and network monitoring utilities:

- **watch_constate** - Monitor network connection states (like vmstat but for connections)
- **watch_zk_conns** - ZooKeeper connection monitoring
- **host_scanner** - Network host scanning and discovery
- **haproxy_stats** - HAProxy statistics monitoring
- **ip2smokeping** - IP to Smokeping integration

Installation:

```bash
brew install chicks-net/chicks/chicks-monitoring-tools
```

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

### chicks-desktop

Meta-package for full desktop environment setup. Installs 50+ CLI tools and provides a setup script for GUI applications and home directory configuration.

CLI tools included: agg, aliae, ansiweather, asciinema, bat, coreutils, cue, datasette, dnscontrol, editorconfig-checker, exiftool, ffmpeg, figlet, flac, fzf, gh, git, git-lfs, glow, go, gping, graphviz, gum, handbrake, hugo, imagemagick, jq, just, lsof, lua, markdownlint-cli2, mtr, nushell, opencode, opentofu, pandoc, podman, r, rclone, ripgrep, rustup, shellcheck, sqlite, starship, terraform-docs, tmux, uv, wget, wtfutil, yt-dlp, chicks-git-tools

Installation:

```bash
brew install chicks-net/chicks/chicks-desktop
```

After installing the formula, run the setup script to complete configuration:

```bash
$(brew --prefix)/share/chicks-desktop/bin/chicks-desktop-setup
```

The setup script will:

- Install GUI applications (Blender, GIMP, Godot, Inkscape, iTerm2, LibreOffice, Processing)
- Install the Claude Code app and Fira Code Nerd Font
- Clone [chicks-home](https://github.com/chicks-net/chicks-home) into `~/Documents/git/chicks-home`
- Create symlinks for dotfiles (`.bashrc`, `.vimrc`, etc.)

You can also install GUI applications manually using the bundled Brewfile:

```bash
brew bundle --file=$(brew --prefix)/share/chicks-desktop/Brewfile
```

## Contributing

- [Code of Conduct](.github/CODE_OF_CONDUCT.md)
- [Contributing Guide](.github/CONTRIBUTING.md) includes a step-by-step guide to our
  [development process](.github/CONTRIBUTING.md#development-process).

## Verifying releases

Each tagged release (e.g. `v0.5`) ships a metadata-only asset bundle
(`homebrew-chicks-<tag>.tar.gz` containing the formula files, `Brewfile`, and
this README), a `checksums.txt` file, a cosign keyless signature
(`.sig` / `.pem` / `.bundle`), an SBOM (`.sbom.json`), and an SLSA provenance
attestation (`multiple.intoto.jsonl`).

### Verify the asset signature with cosign

```bash
TAG="v0.5"
curl -L -O "https://github.com/chicks-net/homebrew-chicks/releases/download/${TAG}/homebrew-chicks-${TAG}.tar.gz"
curl -L -O "https://github.com/chicks-net/homebrew-chicks/releases/download/${TAG}/homebrew-chicks-${TAG}.tar.gz.sig"
curl -L -O "https://github.com/chicks-net/homebrew-chicks/releases/download/${TAG}/homebrew-chicks-${TAG}.tar.gz.pem"

cosign verify-blob \
  --certificate homebrew-chicks-${TAG}.tar.gz.pem \
  --signature homebrew-chicks-${TAG}.tar.gz.sig \
  --certificate-identity-regexp 'https://github.com/chicks-net/homebrew-chicks/.github/workflows/release.yml@refs/tags/${TAG}' \
  --certificate-oidc-issuer 'https://token.actions.githubusercontent.com' \
  homebrew-chicks-${TAG}.tar.gz
```

### Verify SLSA build provenance

```bash
TAG="v0.5"
curl -L -O "https://github.com/chicks-net/homebrew-chicks/releases/download/${TAG}/homebrew-chicks-${TAG}.tar.gz"
curl -L -O "https://github.com/chicks-net/homebrew-chicks/releases/download/${TAG}/multiple.intoto.jsonl"

slsa-verifier verify-artifact \
  --provenance-path multiple.intoto.jsonl \
  --source-uri github.com/chicks-net/homebrew-chicks \
  --source-tag "${TAG}" \
  homebrew-chicks-${TAG}.tar.gz
```

The signature is produced via keyless signing using GitHub Actions OIDC
identities, so there are no long-lived signing keys to trust or rotate - you
only trust the Sigstore Fulcio certificate chain and the workflow identity
printed above.

## Support & Security

- [Getting Support](.github/SUPPORT.md)
- [Security Policy](.github/SECURITY.md)
