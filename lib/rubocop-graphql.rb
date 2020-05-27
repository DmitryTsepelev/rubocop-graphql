# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/graphql"
require_relative "rubocop/graphql/version"
require_relative "rubocop/graphql/inject"
require_relative "rubocop/graphql/node_pattern"

require_relative "rubocop/graphql/field"
require_relative "rubocop/graphql/field_kwargs"
require_relative "rubocop/graphql/schema_member"

RuboCop::GraphQL::Inject.defaults!

require_relative "rubocop/cop/graphql_cops"
