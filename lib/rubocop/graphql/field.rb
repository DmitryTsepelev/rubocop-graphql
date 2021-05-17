# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Field
      extend Forwardable
      extend RuboCop::NodePattern::Macros

      def_delegators :@node, :sibling_index, :parent

      def_node_matcher :field_name, <<~PATTERN
        (send nil? :field (:sym $_) ...)
      PATTERN

      def_node_matcher :field_with_body_name, <<~PATTERN
        (block
        (send nil? :field (:sym $_) ...)...)
      PATTERN

      def_node_matcher :field_description, <<~PATTERN
        (send nil? :field _ _ (:str $_) ...)
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def name
        @name ||= field_name(@node) || field_with_body_name(@node)
      end

      def underscore_name
        @underscore_name ||= begin
          word = name.to_s.dup
          word.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
          word.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
          word.tr!("-", "_")
          word.downcase!
          word
        end
      end

      def description
        @description ||= field_description(@node) || kwargs.description || block.description
      end

      def resolver_method_name
        kwargs.resolver_method_name || name
      end

      def kwargs
        @kwargs ||= Field::Kwargs.new(@node)
      end

      def block
        @block ||= Field::Block.new(@node.parent)
      end

      def schema_member
        @schema_member ||= SchemaMember.new(root_node)
      end

      private

      def root_node
        @node.ancestors.find { |parent| root_node?(parent) }
      end

      def root_node?(node)
        node.parent.nil? || node.parent.module_type? || root_with_siblings?(node.parent)
      end

      def root_with_siblings?(node)
        node.begin_type? && node.parent.nil?
      end
    end
  end
end
