# frozen_string_literal: true

# formula_spec.rb - loads every Formula/*.rb against the Homebrew DSL stub
# and executes install (both File.exist? paths), the test block, and
# caveats. Combined with the stub's platform-branch cycling, every load
# executes every executable line, which keeps Ruby's per-load coverage
# counters from dropping lines no matter which example runs last.

# Local variables (not constants: constants assigned inside a describe
# block land on top-level Object and warn on re-definition).
formula_dir = File.expand_path("../Formula", __dir__)

RSpec.describe "formula coverage harness" do
  # Homebrew file-name -> class-name mapping: ctm.rb -> Ctm,
  # chicks-text-tools.rb -> ChicksTextTools
  def classify(path)
    File.basename(path, ".rb").split("-").map(&:capitalize).join
  end

  # Reset the stub, remove any class a previous example left behind, and
  # load the formula fresh so SimpleCov instruments this load.
  def load_formula(path)
    HomebrewStub.reset!
    klass_name = classify(path)
    Object.send(:remove_const, klass_name) if Object.const_defined?(klass_name, false)
    load path
    Object.const_get(klass_name)
  end

  # First install runs with the real File.exist? (prebuilt-release path);
  # the second forces ctm.rb's source-marker ("main.go") to exist so any
  # source-build fallback executes too. The stub is narrow on purpose -
  # File.exist? for anything else calls through to the original - so
  # RSpec/SimpleCov internals are never lied to.
  def run_formula(klass)
    formula = klass.new
    formula.install
    allow(File).to receive(:exist?).and_call_original
    allow(File).to receive(:exist?).with("main.go").and_return(true)
    formula.install
    formula.instance_exec(&klass.test_block) if klass.test_block
    formula.caveats if formula.respond_to?(:caveats)
    formula
  end

  Dir[File.join(formula_dir, "*.rb")].sort.each do |path|
    describe File.basename(path) do
      it "executes every line, all platform branches included" do
        klass = load_formula(path)
        formula = run_formula(klass)

        # Every formula must carry the metadata brew audit demands.
        expect(klass.test_block).to be_a(Proc)

        dsl = klass.dsl_calls
        expect(dsl[:desc].length).to eq(1)
        expect(dsl[:desc].first.first.first).to be_a(String)
        expect(dsl[:homepage].length).to eq(1)
        expect(dsl[:homepage].first.first.first).to start_with("https://")
        expect(dsl[:url]).not_to be_empty
        expect(dsl[:license].length).to eq(1)

        # A sha256 typo fails here long before brew audit gets a chance.
        dsl[:sha256].each do |args, _kwargs|
          expect(args.first).to match(/\A[0-9a-f]{64}\z/)
        end

        # sanity: the formula object executed without raising
        expect(formula).to be_an_instance_of(klass)
      end
    end
  end

  # ctm.rb is the one formula with real per-platform branching. All four
  # prebuilt release binaries must be declared, so `go` never becomes a
  # build dependency - if a future edit drops a prebuilt arch, this fails.
  # The assertions are structural (not version-pinned) so a routine ctm
  # version bump does not need spec surgery.
  describe "ctm.rb platform matrix" do
    it "declares all four prebuilt binaries so go is never a build dep" do
      klass = load_formula(File.join(formula_dir, "ctm.rb"))
      run_formula(klass)

      urls = klass.dsl_calls[:url].map { |args, _kwargs| args.first }
      prebuilts = urls.grep(%r{/releases/download/v[\d.]+/ctm-(?:darwin|linux)-(?:arm64|amd64)\z})
      expect(prebuilts.map { |u| u[%r{ctm-(\S+)\z}, 1] })
        .to contain_exactly("darwin-arm64", "darwin-amd64", "linux-arm64", "linux-amd64")
      # the remaining url is the source tarball
      expect(urls.size).to eq(prebuilts.size + 1)
      expect(urls.size).to eq(5)

      # one checksum per url
      expect(klass.dsl_calls[:sha256].length).to eq(5)
      expect(klass.dsl_calls[:depends_on]).to be_empty
    end
  end

  # chicks-desktop.rb generates its payload files inline; assert they land
  # in pkgshare with the expected shape.
  describe "chicks-desktop.rb generated files" do
    it "writes a setup script and a Brewfile into pkgshare" do
      klass = load_formula(File.join(formula_dir, "chicks-desktop.rb"))
      run_formula(klass)

      paths = HomebrewStub.file_writes.map(&:first)
      expect(paths).to include(a_string_ending_with("/bin/chicks-desktop-setup"))
      expect(paths).to include(a_string_ending_with("/Brewfile"))

      brewfile = HomebrewStub.file_writes.find { |p, _c| p.end_with?("/Brewfile") }.last
      expect(brewfile).to include('brew "starship"')
      expect(brewfile).to include('cask "iterm2"')

      setup = HomebrewStub.file_writes.find { |p, _c| p.end_with?("/chicks-desktop-setup") }.last
      expect(setup).to include("brew bundle --file=\"$BREWFILE\" --no-lock")
    end
  end
end
