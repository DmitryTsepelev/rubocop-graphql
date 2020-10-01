# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      class OrderedFields < Cop
        MSG = "Fields should be sorted in an alphabetical order within their "\
              "section. "\
              "Field `%<current>s` should appear before `%<previous>s`."

        def investigate(processed_source)
          return if processed_source.blank?

          field_declarations(processed_source.ast)
            .each_cons(2) do |previous, current|
              next if field_name(current) > field_name(previous)
              next if field_name(current) == field_name(previous)

              register_offense(previous, current)
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
