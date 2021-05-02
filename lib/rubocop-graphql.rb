# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/graphql/ext/snake_case"

require_relative "rubocop/graphql"
require_relative "rubocop/graphql/version"
require_relative "rubocop/graphql/inject"
require_relative "rubocop/graphql/description_method"
require_relative "rubocop/graphql/node_pattern"
require_relative "rubocop/graphql/swap_range"

require_relative "rubocop/graphql/argument"
require_relative "rubocop/graphql/argument/block"
require_relative "rubocop/graphql/argument/kwargs"
require_relative "rubocop/graphql/field"
require_relative "rubocop/graphql/field/block"
require_relative "rubocop/graphql/field/kwargs"
require_relative "rubocop/graphql/schema_member"

RuboCop::GraphQL::Inject.defaults!

require_relative "rubocop/cop/graphql_cops"
