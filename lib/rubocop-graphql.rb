# frozen_string_literal: true

require "rubocop"

require_relative "rubocop/graphql"
require_relative "rubocop/graphql/version"
require_relative "rubocop/graphql/inject"

RuboCop::GraphQL::Inject.defaults!

require_relative "rubocop/cop/graphql_cops"
