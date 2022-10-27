# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks if a field has an unnecessary alias.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :name, String, "Name of the user", null: true, alias: :real_name
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :name, "Name of the user" String, null: true, aliias: :name
      #   end
      #
      class UnnecessaryFieldAlias < Base
        include RuboCop::GraphQL::NodePattern

        MSG = "Unnecessary field alias"

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)

          add_offense(node) unless field.name != field.kwargs.alias
        end
      end
    end
  end
end
