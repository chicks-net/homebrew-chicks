cask "gh-observer" do
  version "0.8"
  sha256 "8c3edbd7630a4278a69ef532aba9021fc7f4578ff9ceb650641e53683b0bfe01"

  url "https://github.com/fini-net/gh-observer/archive/refs/tags/v#{version}.tar.gz"
  name "gh-observer"
  desc "Terminal UI for watching GitHub Actions CI/CD workflows with runtime metrics"
  homepage "https://github.com/fini-net/gh-observer"

  depends_on formula: "gh"

  stage_only true

  postflight do
    install_output = system_command "#{HOMEBREW_PREFIX}/bin/gh",
                                    args:         ["extension", "install", "fini-net/gh-observer"],
                                    must_succeed: false

    if install_output.exit_status != 0
      system_command "#{HOMEBREW_PREFIX}/bin/gh",
                     args:         ["extension", "upgrade", "fini-net/gh-observer"],
                     must_succeed: true
    end
  end

  uninstall_postflight do
    system_command "#{HOMEBREW_PREFIX}/bin/gh",
                   args:         ["extension", "remove", "fini-net/gh-observer"],
                   must_succeed: false
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
