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
        def_node_matcher :legacy_dsl?, <<~PATTERN
          (block
            (send
              (const
                (const nil :GraphQL) :Object) :define)
            (args) nil)
        PATTERN

        MSG = "Avoid using legacy based type-based definitions. Use class-based defintions instead."

        def on_block(node)
          return unless node.method_name == :define
          return unless node.receiver.const_type?

          add_offense(node)
        end
      end
    end
  end
end
