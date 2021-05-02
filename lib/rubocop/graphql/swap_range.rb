# frozen_string_literal: true

module RuboCop
  module GraphQL
    module SwapRange
      def swap_range(corrector, current, previous)
        current_range = declaration(current)
        previous_range = declaration(previous)

        src1 = current_range.source
        src2 = previous_range.source

        corrector.replace(current_range, src2)
        corrector.replace(previous_range, src1)
      end

      def declaration(node)
        buffer = processed_source.buffer
        begin_pos = node.source_range.begin_pos
        end_line = buffer.line_for_position(node.loc.expression.end_pos)
        end_pos = buffer.line_range(end_line).end_pos
        Parser::Source::Range.new(buffer, begin_pos, end_pos)
      end
    end
  end
end
