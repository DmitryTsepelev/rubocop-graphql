# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Field should be alphabetically sorted within groups.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :name, String, null: true
      #     field :phone, String, null: true do
      #       argument :something, String, required: false
      #     end
      #   end
      #
      #   # good
      #
      #   class UserType < BaseType
      #     field :phone, String, null: true
      #
      #     field :name, String, null: true
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :phone, String, null: true
      #     field :name, String, null: true
      #   end
      #
      class OrderedFields < Cop
        MSG = "Fields should be sorted in an alphabetical order within their "\
              "section. "\
              "Field `%<current>s` should appear before `%<previous>s`."

        def investigate(processed_source)
          return if processed_source.blank?

          field_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
              next unless consecutive_lines(previous, current)
              next if field_name(current) > field_name(previous)

              register_offense(previous, current)
            end
        end

        def autocorrect(node)
          declarations = field_declarations(processed_source.ast)
          node_index = declarations.map(&:location).find_index(node.location)
          previous_declaration = declarations.to_a[node_index - 1]

          current_range = declaration(node)
          previous_range = declaration(previous_declaration)

          lambda do |corrector|
            swap_range(corrector, current_range, previous_range)
          end
        end

        private

        def register_offense(previous, current)
          message = format(
            self.class::MSG,
            previous: field_name(previous),
            current: field_name(current)
          )
          add_offense(current, message: message)
        end

        def field_name(node)
          if node.block_type?
            field_name(node.send_node)
          else
            node.first_argument.value.to_s
          end
        end

        def consecutive_lines(previous, current)
          previous.source_range.last_line == current.source_range.first_line - 1
        end

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

        def_node_search :field_declarations, <<~PATTERN
          {
            (send nil? :field (:sym _) ...)
            (block
              (send nil? :field (:sym _) ...) ...)
          }
        PATTERN
      end
    end
  end
end
