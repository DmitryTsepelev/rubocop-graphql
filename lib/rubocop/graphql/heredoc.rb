# frozen_string_literal: true

module RuboCop
  module GraphQL
    module Heredoc
      def heredoc?(node)
        (node.str_type? || node.dstr_type?) && node.heredoc?
      end

      def range_including_heredoc(node)
        field = RuboCop::GraphQL::Field.new(node)
        last_heredoc = field.kwargs.instance_variable_get(:@nodes).reverse.find do |kwarg|
                         heredoc?(kwarg.value)
                       end&.value

        range = node.source_range
        range = range.join(last_heredoc.loc.heredoc_end) if last_heredoc

        range_by_whole_lines(range)
      end
    end
  end
end
