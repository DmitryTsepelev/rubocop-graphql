# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks if each field has a description.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :name, String, "Name of the user", null: true
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :name, String, null: true
      #   end
      #
      # Fields built from a resolver, mutation or subscription class are not
      # flagged: graphql-ruby takes their description from that class.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :posts, resolver: PostsResolver
      #   end
      #
      class FieldDescription < Base
        include RuboCop::GraphQL::NodePattern

        MSG = "Missing field description"
        RESTRICT_ON_SEND = %i[field].freeze

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)
          return if field.kwargs.resolver_class

          add_offense(node) unless field.description
        end
      end
    end
  end
end
