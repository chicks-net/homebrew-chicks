cask "gh-observer" do
  version "0.8"
  sha256 "8c3edbd7630a4278a69ef532aba9021fc7f4578ff9ceb650641e53683b0bfe01"

  url "https://github.com/fini-net/gh-observer/archive/refs/tags/v#{version}.tar.gz"
  name "GitHub Observer"
  desc "Terminal UI for watching GitHub Actions CI/CD workflows with runtime metrics"
  homepage "https://github.com/fini-net/gh-observer"
  license "GPL-2.0"

  depends_on formula: "gh"

  # NOTE: This cask uses `stage_only true` because the actual extension binary
  # is installed via `gh extension install` at postflight time. The downloaded
  # tarball is verified by sha256 but its contents are not directly used.
  # Upgrades via `brew upgrade` will pull the latest version from GitHub,
  # which may differ from the version specified in this cask.
  stage_only true

  postflight do
    list_output = system_command "#{HOMEBREW_PREFIX}/bin/gh",
                                 args:         ["extension", "list"],
                                 must_succeed: false
    if list_output.stdout.include?("fini-net/gh-observer")
      system_command "#{HOMEBREW_PREFIX}/bin/gh",
                     args:         ["extension", "upgrade", "fini-net/gh-observer"],
                     must_succeed: true
    else
      system_command "#{HOMEBREW_PREFIX}/bin/gh",
                     args:         ["extension", "install", "fini-net/gh-observer"],
                     must_succeed: true
    end
  end

  uninstall_postflight do
    system_command "#{HOMEBREW_PREFIX}/bin/gh",
                   args:         ["extension", "remove", "fini-net/gh-observer"],
                   must_succeed: false
  end

  test do
    output = shell_output("#{HOMEBREW_PREFIX}/bin/gh extension list 2>&1")
    assert_match "fini-net/gh-observer", output
  end

  caveats <<~EOS
    gh-observer has been installed as a GitHub CLI extension.

    Run it with:
      gh observer

    To upgrade:
      gh extension upgrade fini-net/gh-observer
    Or:
      brew upgrade gh-observer

    To uninstall:
      brew uninstall gh-observer
  EOS
end
