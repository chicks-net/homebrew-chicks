class ChicksMonitoringTools < Formula
  desc "System and network monitoring utilities"
  homepage "https://github.com/chicks-net/chicks-home"
  url "https://github.com/chicks-net/chicks-home/archive/refs/tags/v42.4.tar.gz"
  sha256 "3793bd85f9dde043b65316d31e28b440ec4c1c3bca0257f08d6ca16bfa19e6f0"
  license "GPL-2.0-only"

  def install
    bin.install "bin/watch_constate"
    bin.install "bin/watch_zk_conns"
    bin.install "bin/host_scanner"
    bin.install "bin/haproxy_stats"
    bin.install "bin/ip2smokeping"
  end

  def caveats
    <<~EOS
      Some tools require additional dependencies:
      - watch_constate and watch_zk_conns require netstat (pre-installed on macOS)
      - Perl scripts may require CPAN modules: DateTime, Net::Telnet

      Install Perl modules with cpanm (recommended) or cpan:
        cpanm DateTime Net::Telnet
        # or
        cpan DateTime Net::Telnet
    EOS
  end

  test do
    # Test watch_constate is installed and executable
    assert_path_exists bin/"watch_constate"
    assert_predicate bin/"watch_constate", :executable?

    # Test watch_zk_conns is installed and executable
    assert_path_exists bin/"watch_zk_conns"
    assert_predicate bin/"watch_zk_conns", :executable?

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
