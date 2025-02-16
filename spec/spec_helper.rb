# frozen_string_literal: true

require "rubocop-graphql"
require "rubocop/rspec/support"

spec_helper_glob = File.expand_path("{support}/*.rb", __dir__)
Dir.glob(spec_helper_glob).map(&method(:require))

RSpec.configure do |config|
  config.disable_monkey_patching!
  config.raise_errors_for_deprecations!
  config.raise_on_warning = true
  config.fail_if_no_examples = true

  config.order = :random

  Kernel.srand config.seed

  config.include(ExpectOffense)
end
