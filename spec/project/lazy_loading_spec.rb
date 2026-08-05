# frozen_string_literal: true

require "English"

RSpec.describe "cop lazy loading" do
  def run_script(source)
    Dir.mktmpdir do |dir|
      script = File.join(dir, "script.rb")
      File.write(script, source)
      lib = File.expand_path("../../lib", __dir__)
      output = `#{RbConfig.ruby} -I #{lib} #{script} 2>&1`
      raise "script failed:\n#{output}" unless $CHILD_STATUS.success?

      output
    end
  end

  it "registers every cop file in `lib/rubocop/cop/graphql` exactly once" do
    cop_root = File.expand_path("../../lib/rubocop/cop", __dir__)
    files = Dir[File.join(cop_root, "graphql", "*.rb")]

    department = RuboCop::Cop::Registry.global.cops_for_department(:GraphQL)
    registered = department.map do |cop|
      Object.const_source_location(cop.name).first
    end

    expect(registered.sort).to eq(files)
  end

  it "registers all cops without loading their files" do
    output = run_script(<<~RUBY)
      require 'rubocop-graphql'

      registry = RuboCop::Cop::Registry.global
      loaded = $LOADED_FEATURES.grep(%r{/rubocop/cop/graphql/})

      puts "registered=\#{registry.names.grep(%r{\\AGraphQL/}).size}"
      puts "loaded_cop_files=\#{loaded.size}"
    RUBY

    expect(output).to include("registered=31", "loaded_cop_files=0")
  end

  it "does not register a cop twice when its file is required directly" do
    output = run_script(<<~RUBY)
      require 'rubocop-graphql'

      before = RuboCop::Cop::Registry.global.length
      require 'rubocop/cop/graphql/argument_name'
      after = RuboCop::Cop::Registry.global.length

      puts "stable=\#{before == after}"
      puts "class=\#{RuboCop::Cop::Registry.global.find_by_cop_name('GraphQL/ArgumentName')}"
    RUBY

    expect(output).to include("stable=true", "class=RuboCop::Cop::GraphQL::ArgumentName")
  end
end
