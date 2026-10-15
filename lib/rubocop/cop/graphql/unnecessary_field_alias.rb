# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop prevents defining an unnecessary alias, method, or resolver_method.
      #
      # @example
      #   # good
      #
      #   field :name, String, "Name of the user", null: true, alias: :real_name
      #   field :name, String, "Name of the user", null: true, method: :real_name
      #   field :name, String, "Name of the user", null: true, resolver_method: :real_name
      #   field :name, String, "Name of the user", null: true, hash_key: :real_name
      #
      #   # bad
      #
      #   field :name, "Name of the user" String, null: true, alias: :name
      #   field :name, String, "Name of the user", null: true, method: :name
      #   field :name, String, "Name of the user", null: true, resolver_method: :name
      #   field :name, String, "Name of the user", null: true, hash_key: :name
      #
      class UnnecessaryFieldAlias < Base
        extend AutoCorrector
        include RangeHelp
        include RuboCop::GraphQL::NodePattern

        MSG = "Unnecessary :%<kwarg>s configured"
        RESTRICT_ON_SEND = %i[field].freeze

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)

          if (unnecessary_kwarg = validate_kwargs(field))
            message = format(self.class::MSG, kwarg: unnecessary_kwarg)
            add_offense(node, message: message) do |corrector|
              kwarg_node = node.last_argument.pairs.find do |pair|
                pair.key.value == unnecessary_kwarg.to_sym
              end
              corrector.remove(range_to_remove(kwarg_node))
            end
          end
        end

        private

        # The pair together with exactly one adjoining separator, wherever it sits: a
        # leading `, ` plus any line break, or (for the first pair) the `, ` after it.
        def range_to_remove(pair)
          index = pair.sibling_index
          siblings = pair.parent.children

          if index.positive?
            range_between(siblings[index - 1].source_range.end_pos, pair.source_range.end_pos)
          elsif siblings.size > 1
            range_between(pair.source_range.begin_pos, siblings[1].source_range.begin_pos)
          else
            range_between(pair.parent.left_sibling.source_range.end_pos, pair.source_range.end_pos)
          end
        end

        def validate_kwargs(field) # rubocop:disable Metrics/CyclomaticComplexity
          case field.name
          when field.kwargs.alias then "alias"
          when field.kwargs.method&.value&.value then "method"
          when field.kwargs.resolver_method_name then "resolver_method"
          when field.kwargs.hash_key&.value&.value then "hash_key"
          end
        end
      end
    end
  end
end
