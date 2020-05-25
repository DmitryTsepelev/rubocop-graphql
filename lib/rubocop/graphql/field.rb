# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Field
      extend Forwardable
      extend RuboCop::NodePattern::Macros

      def_delegators :@node, :sibling_index, :parent, :ancestors

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

      def_node_matcher :field_description, <<~PATTERN
        (send nil? :field _ _ (:str $...) ...)
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

      def_node_matcher :resolver_method_option, <<~PATTERN
        (pair (sym :resolver_method) (sym $...))
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def name
        @name ||= field_name(@node).first
      end

      def description
        @name ||= field_description(@node)
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

      def resolver_method_name
        @resolver_method_name ||= kwargs.flat_map { |kwarg| resolver_method_option(kwarg) }.compact.first || name
      end
    end
  end
end
