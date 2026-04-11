class ChicksDesktop < Formula
  desc "Meta-package: full desktop environment with CLI tools, GUI apps and config"
  homepage "https://github.com/chicks-net/homebrew-chicks"
  url "https://github.com/chicks-net/chicks-home/archive/refs/tags/v42.0.tar.gz"
  sha256 "2594b4f1b3830e6f398fef4c84e44b104a92ad69c1a000bcc341145b141168d9"
  license "GPL-2.0-only"

  depends_on "agg"
  depends_on "aliae"
  depends_on "ansiweather"
  depends_on "asciinema"
  depends_on "bat"
  depends_on "chicks-net/chicks/chicks-git-tools"
  depends_on "coreutils"
  depends_on "cue"
  depends_on "datasette"
  depends_on "dnscontrol"
  depends_on "editorconfig-checker"
  depends_on "exiftool"
  depends_on "ffmpeg"
  depends_on "figlet"
  depends_on "flac"
  depends_on "fzf"
  depends_on "gh"
  depends_on "git"
  depends_on "git-lfs"
  depends_on "glow"
  depends_on "go"
  depends_on "gping"
  depends_on "graphviz"
  depends_on "gum"
  depends_on "handbrake"
  depends_on "hugo"
  depends_on "imagemagick"
  depends_on "jq"
  depends_on "just"
  depends_on "lsof"
  depends_on "lua"
  depends_on "markdownlint-cli2"
  depends_on "mtr"
  depends_on "nushell"
  depends_on "opencode"
  depends_on "opentofu"
  depends_on "pandoc"
  depends_on "podman"
  depends_on "r"
  depends_on "rclone"
  depends_on "ripgrep"
  depends_on "rustup"
  depends_on "shellcheck"
  depends_on "sqlite"
  depends_on "starship"
  depends_on "terraform-docs"
  depends_on "tmux"
  depends_on "uv"
  depends_on "wget"
  depends_on "wtfutil"
  depends_on "yt-dlp"

  def install
    (pkgshare/"bin").mkpath
    (pkgshare/"bin/chicks-desktop-setup").write generate_setup_script
    chmod 0755, pkgshare/"bin/chicks-desktop-setup"
    (pkgshare/"Brewfile").write generate_brewfile
  end

  def caveats
    <<~EOS
      chicks-desktop has installed CLI tools via formula dependencies.

      To complete your desktop setup, run:
        #{pkgshare}/bin/chicks-desktop-setup

      This will:
        - Install GUI applications via Homebrew casks (Blender, GIMP, Godot, etc.)
        - Install the Fira Code Nerd Font
        - Clone chicks-net/chicks-home into ~/Documents/git/chicks-home
        - Create symlinks for dotfiles (~/.bashrc, ~/.vimrc, etc.)

      Alternatively, install casks manually:
        brew bundle --file=#{pkgshare}/Brewfile
    EOS
  end

  test do
    assert_predicate pkgshare/"bin/chicks-desktop-setup", :executable?
    assert_path_exists pkgshare/"Brewfile"
  end

  def generate_brewfile
    <<~RUBY
      tap "homebrew/cask-fonts"
      tap "chicks-net/chicks"

      brew "agg"
      brew "aliae"
      brew "ansiweather"
      brew "asciinema"
      brew "bat"
      brew "coreutils"
      brew "cue"
      brew "datasette"
      brew "dnscontrol"
      brew "editorconfig-checker"
      brew "exiftool"
      brew "ffmpeg"
      brew "figlet"
      brew "flac"
      brew "fzf"
      brew "gh"
      brew "git"
      brew "git-lfs"
      brew "glow"
      brew "go"
      brew "gping"
      brew "graphviz"
      brew "gum"
      brew "handbrake"
      brew "hugo"
      brew "imagemagick"
      brew "jq"
      brew "just"
      brew "lsof"
      brew "lua"
      brew "markdownlint-cli2"
      brew "mtr"
      brew "nushell"
      brew "opencode"
      brew "opentofu"
      brew "pandoc"
      brew "podman"
      brew "r"
      brew "rclone"
      brew "ripgrep"
      brew "rustup"
      brew "shellcheck"
      brew "sqlite"
      brew "starship"
      brew "terraform-docs"
      brew "tmux"
      brew "uv"
      brew "wget"
      brew "wtfutil"
      brew "yt-dlp"

      brew "chicks-net/chicks/chicks-git-tools"

      cask "blender"
      cask "claude-code"
      cask "elgato-control-center"
      cask "font-fira-code-nerd-font"
      cask "gimp"
      cask "godot"
      cask "inkscape"
      cask "iterm2"
      cask "libreoffice"
      cask "processing"
    RUBY
  end

  def generate_setup_script
    <<~SCRIPT
      #!/usr/bin/env bash
      set -euo pipefail

      BREWFILE="#{pkgshare}/Brewfile"
      CHICKS_HOME_DIR="$HOME/Documents/git/chicks-home"
      CHICKS_HOME_URL="https://github.com/chicks-net/chicks-home"

      echo "=== chicks-desktop setup ==="
      echo

      # Install casks and additional formulae from Brewfile
      if [[ -f "$BREWFILE" ]]; then
        echo "--- Installing packages from Brewfile ---"
        brew bundle --file="$BREWFILE" --no-lock
      else
        echo "WARNING: Brewfile not found at $BREWFILE"
        echo "Install casks manually or re-install chicks-desktop."
      fi

      echo
      echo "--- Setting up chicks-home ---"

      # Create ~/Documents/git directory
      mkdir -p "$HOME/Documents/git"

      # Clone or update chicks-home
      if [[ -d "$CHICKS_HOME_DIR/.git" ]]; then
        echo "Updating existing chicks-home repository..."
        git -C "$CHICKS_HOME_DIR" pull
      else
        echo "Cloning chicks-home repository..."
        git clone "$CHICKS_HOME_URL" "$CHICKS_HOME_DIR"
      fi

      echo
      echo "--- Creating symlinks ---"

      DOTFILES=(
        ".aliae.yaml"
        ".bcrc"
        ".bashrc"
        ".gitignore"
        ".gitignore_global"
        ".perltidyrc"
        ".pylintrc"
        ".vimrc"
      )

      for dotfile in "${DOTFILES[@]}"; do
        source="$CHICKS_HOME_DIR/$dotfile"
        target="$HOME/$dotfile"

        if [[ -L "$target" ]]; then
          echo "SKIP: $target already a symlink"
        elif [[ -e "$target" ]]; then
          echo "SKIP: $target already exists (not a symlink)"
        elif [[ -f "$source" ]]; then
          ln -s "$source" "$target"
          echo "LINK: $target -> $source"
        else
          echo "SKIP: $source not found in chicks-home"
        fi
      done

      echo
      echo "=== chicks-desktop setup complete ==="
    SCRIPT
  end
end
