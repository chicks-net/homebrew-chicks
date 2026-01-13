class ChicksMonitoringTools < Formula
  desc "System and network monitoring utilities"
  homepage "https://github.com/chicks-net/chicks-home"
  url "https://github.com/chicks-net/chicks-home/archive/refs/tags/v42.0.tar.gz"
  sha256 "2594b4f1b3830e6f398fef4c84e44b104a92ad69c1a000bcc341145b141168d9"
  license "GPL-2.0-only"

  depends_on "lsof"

  def install
    bin.install "bin/watch_constate"
    bin.install "bin/watch_zk_conns"
    bin.install "bin/graph_constate"
    bin.install "bin/host_scanner"
    bin.install "bin/haproxy_stats"
    bin.install "bin/ip2smokeping"
  end

  test do
    # Test watch_constate is installed and executable
    assert_path_exists bin/"watch_constate"
    assert_predicate bin/"watch_constate", :executable?

    # Test watch_zk_conns is installed and executable
    assert_path_exists bin/"watch_zk_conns"
    assert_predicate bin/"watch_zk_conns", :executable?

    # Test graph_constate is installed and executable
    assert_path_exists bin/"graph_constate"
    assert_predicate bin/"graph_constate", :executable?

    # Test host_scanner is installed and executable
    assert_path_exists bin/"host_scanner"
    assert_predicate bin/"host_scanner", :executable?

    # Test haproxy_stats is installed and executable
    assert_path_exists bin/"haproxy_stats"
    assert_predicate bin/"haproxy_stats", :executable?

    # Test ip2smokeping is installed and executable
    assert_path_exists bin/"ip2smokeping"
    assert_predicate bin/"ip2smokeping", :executable?
  end
end
