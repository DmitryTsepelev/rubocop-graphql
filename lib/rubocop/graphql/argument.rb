# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Argument
      extend RuboCop::NodePattern::Macros

      def_node_matcher :argument_description, <<~PATTERN
        (send nil? :argument _ _ (:str $_) ...)
      PATTERN

      def_node_matcher :argument_name, <<~PATTERN
        (send nil? :argument (:sym $_) ...)
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def name
        @name ||= argument_name(@node)
      end

      def description
        @description ||= argument_description(@node) || kwargs.description || block.description
      end

      def kwargs
        @kwargs ||= Argument::Kwargs.new(@node)
      end

      def block
        @block ||= Argument::Block.new(@node.parent)
      end
    end
  end
end
