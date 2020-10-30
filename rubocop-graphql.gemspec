lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "rubocop/graphql/version"

Gem::Specification.new do |spec|
  spec.name = "rubocop-graphql"
  spec.version = RuboCop::GraphQL::VERSION
  spec.authors = ["Dmitry Tsepelev"]
  spec.email = ["dmitry.a.tsepelev@gmail.com"]

  spec.summary = "Automatic performance checking tool for Ruby code."
  spec.description = "A collection of RuboCop cops to improve GraphQL-related code"
  spec.homepage = "https://github.com/DmitryTsepelev/rubocop-graphql"
  spec.license = "MIT"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = `git ls-files -z config lib LICENSE.txt README.md`.split("\x0")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 2.4"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.9"

  spec.add_runtime_dependency "rubocop", ">= 0.87", "< 2"
end
