class Ctm < Formula
  desc "Control Time Machines Corp. network clocks over UDP"
  homepage "https://github.com/chicks-net/ctm"
  url "https://github.com/chicks-net/ctm/archive/refs/tags/v0.2.tar.gz"
  sha256 "b6cb58300cb085f5c514c479d0ae829b8f5f097c8827742ba75a2afc62a8a998"
  license "GPL-2.0-only"

  needs_source_build = true

  on_macos do
    if Hardware::CPU.arm?
      url "https://github.com/chicks-net/ctm/releases/download/v0.2/ctm-darwin-arm64"
      sha256 "055828e8f822a12375d31b8ff7886a54c06dc7abc0f6464d64408d0ac69e2e0c"
      needs_source_build = false
    elsif Hardware::CPU.intel?
      url "https://github.com/chicks-net/ctm/releases/download/v0.2/ctm-darwin-amd64"
      sha256 "424d0a2298c4a8f99df263275c739291d345e0fa4e29e720100a8125054a68f5"
      needs_source_build = false
    end
  end

  on_linux do
    if Hardware::CPU.arm?
      url "https://github.com/chicks-net/ctm/releases/download/v0.2/ctm-linux-arm64"
      sha256 "e773785d9cf29b7635e30fd397ea4f9c87e8dc95a0fe85e90e6740342f676c7f"
      needs_source_build = false
    elsif Hardware::CPU.intel?
      url "https://github.com/chicks-net/ctm/releases/download/v0.2/ctm-linux-amd64"
      sha256 "ca0722b95d2eb28faa967ba4be685c3e73603e97fafa57e84b73c1d82108fbd4"
      needs_source_build = false
    end
  end

  depends_on "go" => :build if needs_source_build

  def install
    if File.exist?("main.go")
      system "go", "build", *std_go_args(ldflags: "-s -w")
    else
      binary = Dir["ctm-*"].first
      bin.install binary => "ctm"
      chmod 0755, bin/"ctm"
    end
  end

  test do
    assert_path_exists bin/"ctm"
    assert_predicate bin/"ctm", :executable?

    help_output = shell_output("#{bin}/ctm help")
    assert_match "ctm", help_output
    assert_match(/subcommand/i, help_output)

    # bare invocation with no args exits 1 (flag.ErrHelp path)
    shell_output("#{bin}/ctm 2>&1", 1)
  end
end
