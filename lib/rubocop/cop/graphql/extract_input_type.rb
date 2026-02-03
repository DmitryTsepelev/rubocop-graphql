# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      class ExtractInputType < Base
        # Checks fields on common prefix groups
        #
        # # @example
        #   # good
        #
        #   class UpdateUser < BaseMutation
        #     argument :uuid, ID, required: true
        #     argument :user_attributes, UserAttributesInputType
        #   end
        #
        #   # bad
        #
        #   class UpdateUser < BaseMutation
        #     argument :uuid, ID, required: true
        #     argument :first_name, String, required: true
        #     argument :last_name, String, required: true
        #   end
        #
        include RuboCop::GraphQL::NodePattern

        MSG = "Consider moving arguments to a new input type"

        def on_class(node)
          schema_member = RuboCop::GraphQL::SchemaMember.new(node)

          if (body = schema_member.body)
            arguments = body.select { |node| argument?(node) && !input_type?(node) }

            excess_arguments = arguments.count - cop_config["MaxArguments"]
            return unless excess_arguments.positive?

            arguments.last(excess_arguments).each do |excess_argument|
              add_offense(excess_argument)
            end
          end
        end

        private

        def input_type?(node)
          type_node = node.arguments[1]
          return false unless type_node&.const_type?

          type_name = type_name_from_const(type_node)
          type_name.end_with?("Input", "InputType")
        end

        def type_name_from_const(node)
          return "" unless node

          if node.children[0].nil?
            node.children[1].to_s
          else
            type_name_from_const(node.children[0]) + "::" + node.children[1].to_s
          end
        end
      end
    end
  end
end
