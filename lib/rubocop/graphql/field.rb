# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Field
      extend Forwardable
      extend RuboCop::NodePattern::Macros

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
        (send nil? :field (:sym $_) ...)
      PATTERN

      def_node_matcher :field_description, <<~PATTERN
        (send nil? :field _ _ (:str $_) ...)
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def name
        field_name(@node)
      end

      def description
        field_description(@node)
      end

      def resolver_method_name
        kwargs.resolver_method_name || name
      end

      def kwargs
        @kwargs ||= FieldKwargs.new(field_kwargs(@node))
      end

      def schema_member
        @schema_member ||= SchemaMember.new(root_node)
      end

      private

      def root_node
        @node.ancestors.find { |parent| root_node?(parent) }
      end

      def root_node?(node)
        node.parent.nil? || root_with_siblings?(node.parent)
      end

      def root_with_siblings?(node)
        node.begin_type? && node.parent.nil?
      end
    end
  end
end
