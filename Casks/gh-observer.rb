cask "gh-observer" do
  arch arm: "arm64", intel: "amd64"
  os macos: "darwin", linux: "linux"

  version "4.0"
  sha256 arm:          "2c646bd85604dafbb72205fd3ab029c3d45679074dc67f6a807a435b63713338",
         intel:        "f5e1fdbf27dba16f31a9cb0d7f815c7acd327fab55f16d24990c6d4d9ca9a175",
         arm64_linux:  "beb31e5594078cbc977e86ae0730f587527ac32e7bff5ea0351990d70d8b6968",
         x86_64_linux: "36324d0878a31b315d9bbe9b34da1b80c32303cba628c11836bce907385cb42f"

  on_macos do
    binary "darwin-#{arch}", target: "gh-observer"
  end
  on_linux do
    binary "linux-#{arch}", target: "gh-observer"
  end

  url "https://github.com/fini-net/gh-observer/releases/download/v#{version}/#{os}-#{arch}"
  name "GitHub Observer"
  desc "Terminal UI for watching GitHub Actions CI/CD workflows with runtime metrics"
  homepage "https://github.com/fini-net/gh-observer"

  livecheck do
    url :url
    strategy :github_latest
  end

  depends_on formula: "gh"

  caveats <<~EOS
    gh-observer has been installed as a standalone binary: #{HOMEBREW_PREFIX}/bin/gh-observer

    Run it with:
      gh-observer [PR_NUMBER | PR_URL | ACTIONS_RUN_URL]
      gh-observer --repo [owner/repo | URL]

    It authenticates with the token from your `gh auth login` (or GITHUB_TOKEN).

    Prefer the `gh observer` extension form instead? Install with:
      gh extension install fini-net/gh-observer
    (remove this cask first to avoid having two copies).
  EOS
end
