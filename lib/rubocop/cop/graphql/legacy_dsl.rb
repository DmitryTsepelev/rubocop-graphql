# frozen_string_literal: true
require 'pry'
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
          (send
            (const
              (const nil? :GraphQL) _) :define)
        PATTERN

        MSG = "Avoid using legacy based type-based definitions. Use class-based defintions instead."

        def on_send(node)
          return unless node.parent.type == :block

          add_offense(node) if legacy_dsl?(node)
        end
      end
    end
  end
end
