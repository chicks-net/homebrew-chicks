# frozen_string_literal: true

# cask_spec.rb - loads every Casks/*.rb against the stub's cask DSL and
# executes postflight (under BOTH gh-extension states so the upgrade-vs-
# install if/else takes both branches on every load), uninstall_postflight,
# and the test block.

# Local variable (not a constant: constants assigned inside a describe
# block land on top-level Object and warn on re-definition).
cask_dir = File.expand_path("../Casks", __dir__)

RSpec.describe "cask coverage harness" do
  Dir[File.join(cask_dir, "*.rb")].sort.each do |path|
    describe File.basename(path) do
      it "executes every line, both postflight branches included" do
        HomebrewStub.reset!
        load path

        cask = HomebrewStub.registered_casks.values.last
        expect(cask).not_to be_nil

        # DSL sanity, derived from the cask itself rather than hardcoded
        # so a version bump does not need spec surgery.
        version = cask.version
        expect(version).to match(/\A\d+(\.\d+)*\z/)
        expect(cask.dsl_calls[:stage_only].first).to eq([[true], {}])
        expect(cask.dsl_calls[:url].first.first.first).to include("/v#{version}.tar.gz")
        expect(cask.dsl_calls[:homepage].first.first.first).to start_with("https://")
        expect(cask.dsl_calls[:depends_on].first.last).to include(formula: "gh")

        # Execute every stored block; postflight runs under both gh states
        # so its if/else executes both branches (see stub file header).
        ctx = HomebrewStub::CaskCommandContext.new
        HomebrewStub.gh_extension_installed = false
        ctx.instance_exec(&cask.blocks[:postflight])
        HomebrewStub.gh_extension_installed = true
        ctx.instance_exec(&cask.blocks[:postflight])
        ctx.instance_exec(&cask.blocks[:uninstall_postflight])
        ctx.instance_exec(&cask.blocks[:test])

        expect(cask.blocks.keys).to contain_exactly(:postflight, :uninstall_postflight, :test)
        expect(cask.caveats).to include("gh observer")

        # The upgrade-vs-install fork took both branches.
        commands = HomebrewStub.system_log
        expect(commands).to include(include("extension", "list"))
        expect(commands).to include(include("extension", "upgrade"))
        expect(commands).to include(include("extension", "install"))
        expect(commands).to include(include("extension", "remove"))
      end
    end
  end
end
