# frozen_string_literal: true

module RuboCop
  module GraphQL
    class FieldKwargs
      extend RuboCop::NodePattern::Macros

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

      def initialize(nodes)
        @nodes = nodes
      end

      def resolver
        @nodes.find { |kwarg| resolver_kwarg?(kwarg) }
      end

      def method
        @nodes.find { |kwarg| method_kwarg?(kwarg) }
      end

      def hash_key
        @nodes.find { |kwarg| hash_key_kwarg?(kwarg) }
      end

      def resolver_method_name
        @resolver_method_name ||= @nodes.flat_map { |kwarg| resolver_method_option(kwarg) }.compact.first
      end
    end
  end
end
