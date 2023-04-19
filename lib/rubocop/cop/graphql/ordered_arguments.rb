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
      class OrderedArguments < Base
        extend AutoCorrector

        include RuboCop::GraphQL::SwapRange

        MSG = "Arguments should be sorted in an alphabetical order within their section. " \
              "Field `%<current>s` should appear before `%<previous>s`."

        def on_class(node)
          declarations_with_blocks = argument_declarations_with_blocks(node)
          declarations_without_blocks = argument_declarations_without_blocks(node)

          argument_declarations = declarations_without_blocks.map do |node|
            arg_name = argument_name(node)
            same_arg_with_block_declaration = declarations_with_blocks.find do |dec|
              argument_name(dec) == arg_name
            end

            same_arg_with_block_declaration || node
          end

          argument_declarations.each_cons(2) do |previous, current|
            next unless consecutive_lines(previous, current)
            next if correct_order?(argument_name(previous), argument_name(current))

            register_offense(previous, current)
          end
        end

        private

        def correct_order?(previous, current)
          # If Order config is provided, we should use it to determine the order
          # Else, we should use alphabetical order
          # e.g. "Order" => [
          #   "id",
          #   "/^id_.*$/",
          #   "/^.*_id$/",
          #   "everything-else",
          #   "/^(created|updated)_at$/"
          # ]
          if (order = cop_config["Order"])
            # For each of previous and current, we should find the first matching order,
            # checking 'everything-else' last
            # If the order is the same, we should use alphabetical order
            # If the order is different, we should use the order
            previous_order = order_index(previous, order)
            current_order = order_index(current, order)

            if previous_order == current_order
              previous <= current
            else
              previous_order < current_order
            end
          else
            previous <= current
          end
        end

        def order_index(field, order)
          everything_else_index = order.length

          order.each_with_index do |order_item, index|
            if order_item == "everything-else"
              everything_else_index = index
            elsif order_item.start_with?("/") && order_item.end_with?("/") # is regex-like?
              return index if field.match?(order_item[1..-2])
            elsif field == order_item
              return index
            end
          end

          everything_else_index
        end

        def register_offense(previous, current)
          message = format(
            self.class::MSG,
            previous: argument_name(previous),
            current: argument_name(current)
          )

          add_offense(current, message: message) do |corrector|
            swap_range(corrector, current, previous)
          end
        end

        def argument_name(node)
          argument = node.block_type? ? node.children.first.first_argument : node.first_argument

          argument.value.to_s
        end

        def consecutive_lines(previous, current)
          previous.source_range.last_line == current.source_range.first_line - 1
        end

        # @!method argument_declarations_without_blocks(node)
        def_node_search :argument_declarations_without_blocks, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN

        # @!method argument_declarations_with_blocks(node)
        def_node_search :argument_declarations_with_blocks, <<~PATTERN
          (block
            (send nil? :argument
              (:sym _)
              ...)
            ...)
        PATTERN
      end
    end
  end
end
