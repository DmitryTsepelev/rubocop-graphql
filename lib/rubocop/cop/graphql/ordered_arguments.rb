# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Arguments should be alphabetically sorted within groups.
      #
      # @example
      #   # good
      #
      #   class UpdateProfile < BaseMutation
      #     argument :email, String, required: false
      #     argument :name, String, required: false
      #   end
      #
      #   # good
      #
      #   class UpdateProfile < BaseMutation
      #     argument :uuid, ID, required: true
      #
      #     argument :email, String, required: false
      #     argument :name, String, required: false
      #   end
      #
      #   # good
      #
      #   class UserType < BaseType
      #     field :posts, PostType do
      #       argument :created_after, ISO8601DateTime, required: false
      #       argument :created_before, ISO8601DateTime, required: false
      #     end
      #   end
      #
      #   # bad
      #
      #   class UpdateProfile < BaseMutation
      #     argument :uuid, ID, required: true
      #     argument :name, String, required: false
      #     argument :email, String, required: false
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :posts, PostType do
      #       argument :created_before, ISO8601DateTime, required: false
      #       argument :created_after, ISO8601DateTime, required: false
      #     end
      #   end
      #
      class OrderedArguments < Cop
        MSG = "Arguments should be sorted in an alphabetical order within their section. " \
              "Field `%<current>s` should appear before `%<previous>s`."

        def investigate(processed_source)
          return if processed_source.blank?

          argument_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next if argument_name(current) > argument_name(previous)

            register_offense(previous, current)
          end
        end

        def autocorrect(node)
          declarations = argument_declarations(processed_source.ast)
          node_index = declarations.map(&:location).find_index(node.location)
          previous_declaration = declarations.to_a[node_index - 1]

          current_range = declaration(node)
          previous_range = declaration(previous_declaration)

          lambda do |corrector|
            swap_range(corrector, current_range, previous_range)
          end
        end

        private

        def declaration(node)
          buffer = processed_source.buffer
          begin_pos = node.source_range.begin_pos
          end_line = buffer.line_for_position(node.loc.expression.end_pos)
          end_pos = buffer.line_range(end_line).end_pos
          Parser::Source::Range.new(buffer, begin_pos, end_pos)
        end

        def swap_range(corrector, range1, range2)
          src1 = range1.source
          src2 = range2.source
          corrector.replace(range1, src2)
          corrector.replace(range2, src1)
        end

        def register_offense(previous, current)
          message = format(
            self.class::MSG,
            previous: argument_name(previous),
            current: argument_name(current)
          )
          add_offense(current, message: message)
        end

        def argument_name(node)
          node.first_argument.value.to_s
        end

        def consecutive_lines(previous, current)
          previous.source_range.last_line == current.source_range.first_line - 1
        end

        def_node_search :argument_declarations, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN
      end
    end
  end
end
