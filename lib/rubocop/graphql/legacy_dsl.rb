# frozen_string_literal: true

module RuboCop
  module GraphQL
    # Matches the legacy DSL object behavior for GraphQL 1.8x and below
    # Example = GraphQL::ObjectType.define do
    #   ....
    #   ....
    # end
    module LegacyDsl
      extend RuboCop::NodePattern::Macros

      def_node_matcher :legacy_dsl?, <<~PATTERN
        (block
          (send
            (const
              (const nil :GraphQL) ...) :define)
          (args) nil)
      PATTERN
    end
  end
end
