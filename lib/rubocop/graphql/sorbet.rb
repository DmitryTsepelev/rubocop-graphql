# frozen_string_literal: true

module RuboCop
  module GraphQL
    module Sorbet
      extend RuboCop::NodePattern::Macros

      def_node_matcher(:sorbet_signature, <<~PATTERN)
        (block (send nil? :sig) (args) ...)
      PATTERN

      def has_sorbet_signature?(node)
        !!sorbet_signature_for(node)
      end

      def sorbet_signature_for(node)
        node.parent.each_descendant.find do |sibling|
          siblings_in_sequence?(sibling, node) &&
            sorbet_signature(sibling)
        end
      end

      private

      def siblings_in_sequence?(first_node, second_node)
        first_node.sibling_index - second_node.sibling_index == - 1
      end
    end
  end
end
