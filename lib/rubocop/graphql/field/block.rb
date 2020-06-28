# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Field
      class Block
        extend RuboCop::NodePattern::Macros

        def_node_matcher :field_block, <<~PATTERN
          (block
            (send nil? :field ...)
            (args)
            $...
          )
        PATTERN

        def_node_matcher :description_kwarg?, <<~PATTERN
          (send nil? :description (str ...))
        PATTERN

        def initialize(field_node)
          @nodes = field_block(field_node) || []
        end

        def description
          @nodes.find { |kwarg| description_kwarg?(kwarg) }
        end
      end
    end
  end
end
