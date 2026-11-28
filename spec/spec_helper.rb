# frozen_string_literal: true

# spec_helper - boots SimpleCov (which must start BEFORE any formula/cask
# file is loaded, hence its position at the top of this file) and then the
# Homebrew DSL stub the coverage harness executes formulas against.

require "simplecov"

# lcov is what codecov/codecov-action uploads from .github/workflows/
# ruby-tests.yml. The HTML formatter stays off - nobody opens it on a
# runner, and it slows the suite down for nothing.
require "simplecov-lcov"
SimpleCov::Formatter::LcovFormatter.config do |config|
  config.report_with_single_file = true
  config.single_report_path = "coverage/lcov.info"
end
SimpleCov.formatter = SimpleCov::Formatter::LcovFormatter

SimpleCov.start do
  # Only Formula/ and Casks/ are the product; the stub and the specs are
  # infrastructure and stay out of the report.
  add_filter do |source|
    !source.filename.match?(%r{/(Formula|Casks)/})
  end
end

require_relative "support/homebrew_dsl_stub"

RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end
  config.mock_with :rspec
  config.order = :random
end
