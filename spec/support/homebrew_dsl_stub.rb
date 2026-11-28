# frozen_string_literal: true

# Homebrew DSL stub for the formula/cask coverage harness.
#
# Formulas and casks are Ruby programs written against a large DSL (`desc`,
# `url`, `bin.install`, `test do`, ...). Homebrew itself is not loadable
# outside a real brew installation, so this file defines just enough of the
# DSL - as RECORDING stubs - for the specs to `load` every file under
# Formula/ and Casks/ and execute every line of it.
#
# What that buys us: execution coverage of the Ruby, including every
# platform branch. Ruby's coverage counters do not accumulate across
# re-loads of the same file, so the harness is built around a stronger
# invariant instead: EVERY load of a formula or cask executes every
# executable line. Concretely:
#
#   * on_macos/on_linux blocks are platform-gated in real Homebrew; the
#     stub runs them unconditionally, cycling the fake cpu through
#     [:arm, :intel] each time, so all four os/cpu branch combinations
#     execute (ctm.rb carries a url/sha256 pair for each).
#   * The specs run `install` twice per load, once with the real
#     File.exist? and once with it stubbed true, so source-build fallback
#     branches execute too.
#   * The cask specs run postflight under both gh-extension states so its
#     upgrade-vs-install if/else takes both branches.
#
# What this does not buy us: behavior. Stubbed helpers return canned
# values and the Minitest-style asserts are vacuous recorders, so a test
# block passing here proves nothing about the real tool. `brew test` in
# brew-formula-test.yml remains the source of truth for real installs.
#
# The stub mirrors Homebrew's own top-level namespace (Formula, Hardware,
# HOMEBREW_PREFIX and the `cask` entry point). This process never loads
# real Homebrew, and nothing else shares the namespace.

module HomebrewStub
  # Fake path object backing bin, pkgshare, testpath, and friends.
  # Nothing ever touches the filesystem; writes are recorded instead.
  class FakePath
    def initialize(path = "/opt/homebrew")
      @path = path.to_s
    end

    # bin/"ctm", (pkgshare/"bin").mkpath, ...
    def /(other)
      self.class.new("#{@path}/#{other}")
    end

    # bin.install "bin/comify" / bin.install binary => "ctm"
    def install(*sources)
      HomebrewStub.install_log << [@path, sources]
      self
    end

    def mkpath
      self
    end

    def write(content = nil)
      HomebrewStub.file_writes << [@path, content]
      self
    end

    def exist?
      true
    end

    def executable?
      true
    end

    def to_s
      @path
    end

    def to_str
      @path
    end

    def inspect
      "#<#{self.class.name} #{@path}>"
    end
  end

  # Result shape of Homebrew's system_command, used by cask postflight.
  class CommandResult
    attr_reader :stdout

    def initialize(stdout)
      @stdout = stdout
    end
  end

  # Base class every Formula/*.rb inherits from.
  class Formula
    class << self
      # Recorded class-level DSL calls: desc, homepage, url, sha256,
      # license, depends_on, ... - each entry is [args, kwargs].
      def dsl_calls
        @dsl_calls ||= Hash.new { |h, k| h[k] = [] }
      end

      # See the file header: blocks run unconditionally under both arches
      # so every platform branch executes on every load. The block keeps
      # the class body's binding, which is how `needs_source_build = false`
      # in ctm.rb reaches the class-level local.
      def on_macos(&block)
        HomebrewStub.with_arch(%i[arm intel], &block)
      end

      def on_linux(&block)
        HomebrewStub.with_arch(%i[arm intel], &block)
      end

      # `test do ... end` stores its block for the spec to instance_exec.
      def test(&block)
        @test_block = block
      end

      def test_block
        @test_block
      end

      # Anything unrecognized at the class level is Homebrew DSL: record
      # it and move on. That is deliberately permissive - the point is
      # exercising lines, not validating the DSL (brew audit does that).
      def method_missing(dsl, *args, **kwargs, &block)
        dsl_calls[dsl] << [args, kwargs]
        nil
      end

      def respond_to_missing?(_name, _include_private = false)
        true
      end
    end

    # Path helpers available inside install and test blocks.
    def bin
      @bin ||= FakePath.new("/opt/homebrew/bin")
    end

    def pkgshare
      @pkgshare ||= FakePath.new("/opt/homebrew/opt/stub/share")
    end

    def share
      @share ||= FakePath.new("/opt/homebrew/share")
    end

    def prefix
      @prefix ||= FakePath.new("/opt/homebrew")
    end

    def man1
      @man1 ||= FakePath.new("/opt/homebrew/share/man/man1")
    end

    def testpath
      @testpath ||= FakePath.new("/tmp/stub-testpath")
    end

    # Kernel#system is shadowed on purpose: install/test blocks must never
    # exec anything real, they only record.
    def system(*args)
      HomebrewStub.system_log << args
      true
    end

    def chmod(_mode, *paths)
      HomebrewStub.chmod_log << paths
      true
    end

    def std_go_args(**_kwargs)
      ["-s", "-w"]
    end

    def std_cargo_args
      ["--root", "/tmp/stub-cargo-root"]
    end

    def shell_output(_command, _expected_exit_status = nil)
      "stubbed shell output\n"
    end

    def pipe_output(_command, _stdin = nil, **_kwargs)
      "stubbed pipe output\n"
    end

    # Minitest-style assertions from Homebrew's test harness, vacuous by
    # design (see file header). They return nil like real asserts do.
    def assert_equal(*); end

    def assert_match(*); end

    def assert_path_exists(*); end

    def assert_predicate(*); end

    def assert_output(*); end
  end

  # DSL context for a Casks/*.rb file, instance_eval'd by the top-level
  # `cask` entry point below.
  class CaskDSL
    attr_reader :token, :blocks

    def initialize(token)
      @token = token
      @blocks = {}
    end

    # Recorded DSL calls, same shape as Formula.dsl_calls.
    def dsl_calls
      @dsl_calls ||= Hash.new { |h, k| h[k] = [] }
    end

    # Getter/setter dual: `version "0.8"` stores, while
    # `url ".../v#{version}.tar.gz"` reads.
    def version(value = nil)
      @version = value unless value.nil?
      @version
    end

    def caveats(text = nil)
      @caveats = text unless text.nil?
      @caveats
    end

    def postflight(&block)
      @blocks[:postflight] = block
    end

    def uninstall_postflight(&block)
      @blocks[:uninstall_postflight] = block
    end

    def test(&block)
      @blocks[:test] = block
    end

    def method_missing(dsl, *args, **kwargs, &block)
      dsl_calls[dsl] << [args, kwargs]
      nil
    end

    def respond_to_missing?(_name, _include_private = false)
      true
    end
  end

  # Execution context for cask postflight/test blocks.
  class CaskCommandContext
    # Returns canned output the postflight branches on: `gh extension
    # list` "reports" the extension installed (or not), which flips the
    # cask's upgrade-vs-install if/else. The specs run postflight under
    # both states so both branches execute on every load.
    def system_command(_command, args: [], must_succeed: true)
      HomebrewStub.system_log << args
      listed = args.include?("list") && HomebrewStub.gh_extension_installed
      CommandResult.new(listed ? "gh-observer  fini-net/gh-observer" : "")
    end

    def shell_output(_command, _expected_exit_status = nil)
      "stubbed shell output\n"
    end

    def assert_match(*); end
  end

  class << self
    attr_accessor :arch, :gh_extension_installed

    # Fake platform state, reset before every example.
    def reset!
      @arch = :arm
      @gh_extension_installed = false
      @system_log = []
      @install_log = []
      @file_writes = []
      @chmod_log = []
      @registered_casks = {}
    end

    # Run the block once per arch in arches, restoring the previous arch.
    # This is what lets a single load of ctm.rb execute all four of its
    # url/sha256 branches.
    def with_arch(arches)
      previous = @arch
      arches.each do |arch|
        @arch = arch
        yield
      end
      @arch = previous
    end

    def system_log
      @system_log ||= []
    end

    def install_log
      @install_log ||= []
    end

    def file_writes
      @file_writes ||= []
    end

    def chmod_log
      @chmod_log ||= []
    end

    def registered_casks
      @registered_casks ||= {}
    end
  end
  reset!
end

# Homebrew's Hardware::CPU, driven by the fake arch instead of the host.
module Hardware
  module CPU
    class << self
      def arm?
        HomebrewStub.arch == :arm
      end

      def intel?
        HomebrewStub.arch == :intel
      end
    end
  end
end

# Real Homebrew is a top-level constant; so is the stub.
Formula = HomebrewStub::Formula

# Cask files interpolate HOMEBREW_PREFIX inside postflight blocks.
HOMEBREW_PREFIX = "/opt/homebrew" unless defined?(HOMEBREW_PREFIX)

# Entry point for Casks/*.rb: cask "token" do ... end
def cask(token, &block)
  HomebrewStub.registered_casks[token] = HomebrewStub::CaskDSL.new(token).tap do |dsl|
    dsl.instance_eval(&block)
  end
end
