# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks whether field names are snake_case.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :first_name, String, null: true
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :firstName, String, null: true
      #   end
      #
      class FieldName < Cop
        include RuboCop::GraphQL::NodePattern

        using RuboCop::GraphQL::Ext::SnakeCase

        MSG = "Use snake_case for field names"

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)
          return if field.name.snake_case?

          add_offense(node)
        end
      end
    end
  end
end
