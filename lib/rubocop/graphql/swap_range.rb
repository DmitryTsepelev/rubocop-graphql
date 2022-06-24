# frozen_string_literal: true

module RuboCop
  module GraphQL
    module SwapRange
      include RuboCop::Cop::RangeHelp

      def swap_range(corrector, current, previous)
        current_range = declaration(current)
        previous_range = declaration(previous)

        corrector.insert_before(previous_range, current_range.source)
        corrector.remove(current_range)
      end

      def declaration(node)
        buffer = processed_source.buffer
        begin_pos = range_by_whole_lines(node.source_range).begin_pos
        end_line = buffer.line_for_position(node.loc.expression.end_pos)
        end_pos = range_by_whole_lines(buffer.line_range(end_line),
                                       include_final_newline: true).end_pos
        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end
    end
  end
end
