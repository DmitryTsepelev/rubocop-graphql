# frozen_string_literal: true

module RuboCop
  module GraphQL
    # Shared methods to check duplicated definitions
    module NodeUniqueness
      def current_class_name(node)
        node.each_ancestor(:class).first.defined_module_name
      end

      def nested_class?(node)
        node.each_ancestor(:class).any?
      end
    end
  end
end
