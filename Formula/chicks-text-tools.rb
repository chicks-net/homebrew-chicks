class ChicksTextTools < Formula
  desc "Text manipulation utilities: comify, ruler, roll, closefh"
  homepage "https://github.com/chicks-net/chicks-home"
  url "https://github.com/chicks-net/chicks-home/archive/refs/tags/v42.0.tar.gz"
  sha256 "2594b4f1b3830e6f398fef4c84e44b104a92ad69c1a000bcc341145b141168d9"
  license "GPL-2.0"

  depends_on "lsof"

  def install
    bin.install "bin/comify"
    bin.install "bin/ruler"
    bin.install "bin/roll"
    bin.install "bin/closefh"
  end

  test do
    # Test comify: converts newlines to commas
    output = pipe_output("#{bin}/comify", "line1\nline2\nline3\n")
    assert_equal "line1,line2,line3,\n", output

    # Test ruler: displays character ruler
    output = shell_output("#{bin}/ruler")
    assert_match(/1.*2.*3.*4.*5/, output)
    assert_match(/123456789/, output)

    # Test roll: single die (1-6)
    output = shell_output("#{bin}/roll d6")
    assert_match(/roll 1: [1-6]/, output)

    # Test roll: multiple dice with total
    output = shell_output("#{bin}/roll 2d6")
    assert_match(/total:\s+\d+\/12/, output)

    # Test closefh: verify it runs (tests lsof dependency)
    output = shell_output("#{bin}/closefh /nonexistent/file.txt 2>&1")
    assert_match(/not opened/, output)
  end
end
