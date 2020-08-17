# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # This cop checks if the length of a resolver method exceeds some maximum value.
      # Comment lines can optionally be ignored.
      #
      # The maximum allowed length is configurable using the Max option.
      class ResolverMethodLength < Cop
        include RuboCop::Cop::ConfigurableMax
        include RuboCop::Cop::CodeLength

        MSG = "ResolverMethod has too many lines. [%<total>d/%<max>d]"

        def_node_matcher :field_definition, <<~PATTERN
          (send nil? :field (sym $...) ...)
        PATTERN

        def on_def(node)
          excluded_methods = cop_config["ExcludedMethods"]
          return if excluded_methods.include?(String(node.method_name))

          if field_is_defined?(node)
            length = code_length(node)

            return unless length > max_length

            add_offense(node, message: message(length))
          end
        end
        alias on_defs on_def

        private

        def code_length(node)
          node.source.lines[1..-2].count { |line| !irrelevant_line(line) }
        end

        def field_is_defined?(node)
          node.parent
              .children
              .flat_map { |child| field_definition(child) }
              .include?(node.method_name)
        end

        def message(length)
          format(MSG, total: length, max: max_length)
        end
      end
    end
  end
end
