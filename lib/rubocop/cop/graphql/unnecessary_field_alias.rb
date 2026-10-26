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
              remove_pair(corrector, kwarg_node)
            end
          end
        end

        private

        def remove_pair(corrector, pair)
          comment = comment_before_last_pair(pair)
          comma = comma_before(comment) if comment

          if comma
            corrector.remove(comma)
            corrector.remove(range_between(comment.source_range.end_pos, pair.source_range.end_pos))
          else
            corrector.remove(range_to_remove(pair))
          end
        end

        def range_to_remove(pair)
          if (next_pair = pair.right_sibling)
            range_between(pair.source_range.begin_pos, next_pair.source_range.begin_pos)
          else
            previous = pair.left_sibling || pair.parent.left_sibling
            range_between(previous.source_range.end_pos, pair.source_range.end_pos)
          end
        end

        def comment_before_last_pair(pair)
          return if pair.right_sibling || !last_on_its_line?(pair)

          previous = pair.left_sibling || pair.parent.left_sibling
          processed_source.comment_at_line(previous.last_line)
        end

        def last_on_its_line?(node)
          line_end = processed_source.buffer.line_range(node.last_line).end_pos
          range_between(node.source_range.end_pos, line_end).source.strip.empty?
        end

        def comma_before(comment)
          comment_begin = comment.source_range.begin_pos
          line_begin = comment_begin - comment.loc.column
          offset = processed_source.buffer.source[line_begin...comment_begin].rindex(/,\s*\z/)
          return unless offset

          range_between(line_begin + offset, line_begin + offset + 1)
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
