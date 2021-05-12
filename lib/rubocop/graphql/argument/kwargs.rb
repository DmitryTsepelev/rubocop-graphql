# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Argument
      class Kwargs
        extend RuboCop::NodePattern::Macros

        def_node_matcher :argument_kwargs, <<~PATTERN
          (send nil? :argument
            ...
            (hash
              $...
            )
          )
        PATTERN

        def_node_matcher :description_kwarg?, <<~PATTERN
          (pair (sym :description) ...)
        PATTERN

        def initialize(argument_node)
          @nodes = argument_kwargs(argument_node) || []
        end

        def description
          @nodes.find { |kwarg| description_kwarg?(kwarg) }
        end
      end
    end
  end
end
