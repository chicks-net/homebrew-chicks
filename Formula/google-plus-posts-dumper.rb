class GooglePlusPostsDumper < Formula
  desc "Convert Google+ Takeout archives to Markdown files"
  homepage "https://github.com/chicks-net/google-plus-posts-dumper"
  url "https://github.com/chicks-net/google-plus-posts-dumper/archive/refs/tags/v1.0.tar.gz"
  sha256 "97b5fbf4b9a4a6e803e8ae9735efdef45245bebba85f8f7086a4af6f4766b42b"
  license "GPL-2.0-only"

  depends_on "rust" => :build

  def install
    system "cargo", "install", *std_cargo_args
  end

  test do
    # Verify binary is installed and executable
    assert_path_exists bin/"google-plus-posts-dumper"
    assert_predicate bin/"google-plus-posts-dumper", :executable?

    # Test that running without arguments shows expected error/usage
    output = shell_output("#{bin}/google-plus-posts-dumper 2>&1", 101)
    assert_match(/usage|argument|required|directory/i, output)

    # Test with minimal directory structure
    (testpath/"input").mkpath
    (testpath/"output").mkpath
    system bin/"google-plus-posts-dumper", testpath/"input", testpath/"output"
    assert_path_exists testpath/"output"
  end
end
