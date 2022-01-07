# frozen_string_literal: true

module RuboCop
  module GraphQL
    # Shared methods to check duplicated definitions
    module NodeUniqueness
      def current_class_name(node)
        node.each_ancestor(:class).first.defined_module_name
      end
    end
  end
end
