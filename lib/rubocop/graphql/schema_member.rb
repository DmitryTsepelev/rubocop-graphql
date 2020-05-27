# frozen_string_literal: true

module RuboCop
  module GraphQL
    class SchemaMember
      extend RuboCop::NodePattern::Macros

      def_node_matcher :class_contents, <<~PATTERN
        (class _ _ $_)
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def find_method_definition(method_name)
        body.find { |node| node.def_type? && node.method_name == method_name }
      end

      def body
        contents = class_contents(@node)

        if contents.nil?
          []
        elsif contents.begin_type?
          contents.child_nodes
        else
          [contents]
        end
      end
    end
  end
end
