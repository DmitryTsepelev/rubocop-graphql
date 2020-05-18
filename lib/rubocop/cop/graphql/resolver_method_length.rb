# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # This cop checks if the length of a resolver method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      # The maximum allowed length is configurable.
      class ResolverMethodLength < Cop
        include RuboCop::Cop::ConfigurableMax
        include RuboCop::Cop::TooManyLines

        LABEL = "ResolverMethod"

        def_node_matcher :field_definition, <<~PATTERN
          (send nil? :field (:sym $...) ...)
        PATTERN

        def on_def(node)
          excluded_methods = cop_config["ExcludedMethods"]
          return if excluded_methods.include?(String(node.method_name))

          check_code_length(node) if field_is_defined?(node)
        end
        alias on_defs on_def

        private

        def field_is_defined?(node)
          node.parent.children.flat_map { |child| field_definition(child) }.include?(node.method_name)
        end

        def cop_label
          LABEL
        end
      end
    end
  end
end
