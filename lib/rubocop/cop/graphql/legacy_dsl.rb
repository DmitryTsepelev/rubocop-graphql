# frozen_string_literal: true

module RuboCop
  module GraphQL
    # Matches the legacy DSL object behavior for GraphQL 1.8x and below
    # Example = GraphQL::ObjectType.define do
    #   ....
    #   ....
    # end
    module Cop
      class LegacyDsl < Base
        include RuboCop::GraphQL::NodePattern

        MSG = "Avoid using legacy based type-based definitions. Use class-based defintions instead."

        def on_send(node)
          return unless legacy_dsl?(node)
        end
      end
    end
  end
end
