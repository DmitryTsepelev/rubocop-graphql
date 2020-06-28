# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Argument
      class Block
        extend RuboCop::NodePattern::Macros

        def_node_matcher :argument_block, <<~PATTERN
          (block
            (send nil? :argument ...)
            (args)
            $...
          )
        PATTERN

        def_node_matcher :description_kwarg?, <<~PATTERN
          (send nil? :description (str ...))
        PATTERN

        def initialize(argument_node)
          @nodes = argument_block(argument_node) || []
        end

        def description
          @nodes.find { |kwarg| description_kwarg?(kwarg) }
        end
      end
    end
  end
end
