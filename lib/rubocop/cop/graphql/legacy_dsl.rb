# frozen_string_literal: true

module RuboCop
  module Cop
    # Matches the legacy DSL object behavior for GraphQL 1.8x and below
    # Example = GraphQL::ObjectType.define do
    #   ....
    #   ....
    # end
    module GraphQL
      class LegacyDsl < Base
        extend RuboCop::NodePattern::Macros

        def_node_matcher :legacy_dsl?, <<~PATTERN
          (block
            (send
              (const
                (const nil? :GraphQL) ...) :define)
            (args) nil)
        PATTERN

        MSG = "Avoid using legacy based type-based definitions. Use class-based defintions instead."

        def on_send(node)
          add_offense(node) if legacy_dsl?(node)
        end
      end
    end
  end
end
