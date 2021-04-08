# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Field
      class Block
        extend RuboCop::NodePattern::Macros
        include DescriptionMethod

        def_node_matcher :field_block, <<~PATTERN
          (block
            (send nil? :field ...)
            (args)
            $...
          )
        PATTERN

        def initialize(field_node)
          @nodes = field_block(field_node) || []
        end

        def description
          find_description_method(@nodes)
        end
      end
    end
  end
end
