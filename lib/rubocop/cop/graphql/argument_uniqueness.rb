# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop detects duplicate argument definitions
      #
      # @example
      #   # good
      #
      #   class BanUser < BaseMutation
      #     argument :user_id, ID, required: true
      #   end
      #
      #   # bad
      #
      #   class BanUser < BaseMutation
      #     argument :user_id, ID, required: true
      #     argument :user_id, ID, required: true
      #   end
      #
      class ArgumentUniqueness < Base
        MSG = "Argument names should only be defined once per block. "\
              "Argument `%<current>s` is duplicated%<field_name>s."

        def on_class(node)
          return if nested_class?(node)

          # { "MyClassName" => { "test_field" => <Set: {"field_arg_name"}> } }
          argument_names_by_field_by_class = Hash.new do |h, k|
            h[k] = Hash.new do |h1, k1|
              h1[k1] = Set.new
            end
          end

          argument_declarations(node).each do |current|
            current_field_name = field_name(current)
            current_argument_name = argument_name(current)
            class_name = current_class_name(current)

            argument_names = if current_field_name
                               argument_names_by_field_by_class[class_name][current_field_name]
                             else
                               argument_names_by_field_by_class[class_name][:root]
                             end

            unless argument_names.include?(current_argument_name)
              argument_names.add(current_argument_name)
              next
            end

            register_offense(current)
          end
        end

        private

        def current_class_name(node)
          node.each_ancestor(:class).first.defined_module_name
        end

        def nested_class?(node)
          node.each_ancestor(:class).any?
        end

        def register_offense(current)
          current_field_name = field_name(current)
          field_name_message = " in field `#{current_field_name}`" if current_field_name

          message = format(
            self.class::MSG,
            current: argument_name(current),
            field_name: field_name_message
          )

          add_offense(current, message: message)
        end

        def argument_name(node)
          node.first_argument.value.to_s
        end

        # Find parent field block, if available
        def field_name(node)
          return if node.nil?

          is_field_block = node.block_type? &&
                           node.respond_to?(:method_name) &&
                           node.method_name == :field
          return node.send_node.first_argument.value.to_s if is_field_block

          field_name(node.parent)
        end

        def_node_search :argument_declarations, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN
      end
    end
  end
end
