# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      class Field
        extend Forwardable
        extend NodePattern::Macros

        def_delegators :@node, :sibling_index, :parent

        def_node_matcher :field_kwargs, <<~PATTERN
          (send nil? :field
            ...
            (hash
              $...
            )
          )
        PATTERN

        def_node_matcher :field_name, <<~PATTERN
          (send nil? :field (:sym $...) ...)
        PATTERN

        def_node_matcher :resolver_kwarg?, <<~PATTERN
          (pair (sym :resolver) ...)
        PATTERN

        def_node_matcher :method_kwarg?, <<~PATTERN
          (pair (sym :method) ...)
        PATTERN

        def_node_matcher :hash_key_kwarg?, <<~PATTERN
          (pair (sym :hash_key) ...)
        PATTERN

        attr_reader :node

        def initialize(node)
          @node = node
        end

        def name
          @name ||= field_name(@node).first
        end

        def kwargs
          @kwargs ||= field_kwargs(@node) || []
        end

        def resolver
          kwargs.find { |kwarg| resolver_kwarg?(kwarg) }
        end

        def method
          kwargs.find { |kwarg| method_kwarg?(kwarg) }
        end

        def hash_key
          kwargs.find { |kwarg| hash_key_kwarg?(kwarg) }
        end
      end
    end
  end
end
