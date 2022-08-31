# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Fields should be alphabetically sorted within groups.
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
      class OrderedFields < Base
        extend AutoCorrector

        include RuboCop::GraphQL::SwapRange

        MSG = "Fields should be sorted in an alphabetical order within their "\
              "section. "\
              "Field `%<current>s` should appear before `%<previous>s`."

        def on_class(node)
          field_declarations(node).each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next if field_name(current) >= field_name(previous)

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

          add_offense(current, message: message) do |corrector|
            swap_range(corrector, current, previous)
          end
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

        # @!method field_declarations(node)
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
