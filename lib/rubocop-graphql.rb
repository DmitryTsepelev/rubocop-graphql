# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/graphql"
require_relative "rubocop/graphql/version"
require_relative "rubocop/graphql/inject"
require_relative "rubocop/graphql/node_pattern"
require_relative "rubocop/graphql/field"

RuboCop::GraphQL::Inject.defaults!

require_relative "rubocop/cop/graphql_cops"
