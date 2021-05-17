# frozen_string_literal: true

module RuboCop
  module Cop
    # This cop checks whether type definitions are class-based or legacy.
    #
    # @example
    #   # good
    #
    #   class Example < BaseType
    #     ....
    #   end
    #
    #   # bad
    #
    #   Example = GraphQL::ObjectType.define do
    #     ....
    #     ....
    #   end
    #
    module GraphQL
      class LegacyDsl < Base
        def_node_matcher :legacy_dsl?, <<~PATTERN
          (block
            (send
              (const
                (const nil? :GraphQL) _) :define)
            ...
          )
        PATTERN

        MSG = "Avoid using legacy based type-based definitions. Use class-based defintions instead."

        def on_send(node)
          return unless node.parent.type == :block

          add_offense(node.parent) if legacy_dsl?(node.parent)
        end
      end
    end
  end
end
