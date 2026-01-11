class ChicksGitTools < Formula
  desc "Git/GitHub automation: repos-summary, github_fix_https, apply-ruleset"
  homepage "https://github.com/chicks-net/chicks-home"
  url "https://github.com/chicks-net/chicks-home/archive/refs/tags/v42.0.tar.gz"
  sha256 "2594b4f1b3830e6f398fef4c84e44b104a92ad69c1a000bcc341145b141168d9"
  license "GPL-2.0-only"

  depends_on "gh"
  depends_on "git"
  depends_on "jq"

  def install
    bin.install "bin/repos-summary"
    bin.install "github/github_fix_https"
    bin.install "github/apply-ruleset"
    pkgshare.install "github/rulesets"
  end

  test do
    # Test repos-summary is installed and executable
    assert_path_exists bin/"repos-summary"
    assert_predicate bin/"repos-summary", :executable?

    # Test github_fix_https runs without crashing
    output = shell_output("#{bin}/github_fix_https 2>&1")
    assert_match(/could not identify repo url|not a git repository|already using ssh/i, output)

    # Test apply-ruleset requires arguments
    output = shell_output("#{bin}/apply-ruleset 2>&1", 1)
    assert_match(/not found|usage|argument|requires|ruleset/i, output)

    # Verify rulesets installed and are valid JSON
    assert_path_exists pkgshare/"rulesets/default-linear.json"
    assert_path_exists pkgshare/"rulesets/require-pr.json"
    system "jq", ".", "#{pkgshare}/rulesets/default-linear.json"
    system "jq", ".", "#{pkgshare}/rulesets/require-pr.json"
  end
end
