# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks if each argument has an unnecessary camelize.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :name, String, "Name of the user", null: true do
      #       argument :filter, String, required: false, camelize: false
      #     end
      #   end
      #
      #  # bad
      #
      #   class UserType < BaseType
      #     field :name, String, "Name of the user", null: true do
      #       argument :filter, String, required: false, camelize: false
      #     end
      #   end
      #
      #  # bad
      #
      #   class UserType < BaseType
      #     field :name, String, "Name of the user", null: true do
      #       argument :filter, String, required: false, camelize: true
      #     end
      #   end
      #
      class UnnecessaryArgumentCamelize < Base
        include RuboCop::GraphQL::NodePattern

        MSG = "Unnecessary argument camelize"

        def on_send(node)
          return unless argument?(node)

          argument = RuboCop::GraphQL::Argument.new(node)

          add_offense(node) if argument.name.name.split("_").length < 2 && !argument.kwargs.camelize.nil?
        end
      end
    end
  end
end
