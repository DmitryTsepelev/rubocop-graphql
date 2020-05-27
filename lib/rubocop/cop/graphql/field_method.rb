# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop prevents defining unnecessary resolver methods in cases
      #  when :method option can be used
      #
      # @example
      #   # good
      #
      #   class Types::UserType < Types::BaseObject
      #     field :phone, String, null: true, method: :home_phone
      #   end
      #
      #   # bad
      #
      #   class Types::UserType < Types::BaseObject
      #     field :phone, String, null: true
      #
      #     def phone
      #       object.home_phone
      #     end
      #   end
      #
      class FieldMethod < Cop
        include RuboCop::GraphQL::NodePattern

        def_node_matcher :method_to_use, <<~PATTERN
          (def
            _
            (args)
            (send
              (send nil? :object) $_
            )
          )
        PATTERN

        MSG = "Use method: :%<method_name>s"

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)

          method_name = field.resolver_method_name
          method_definition = field.schema_member.find_method_definition(method_name)

          if (method_name = method_to_use(method_definition))
            add_offense(node, message: message(method_name))
          end
        end

        private

        def message(method_name)
          format(MSG, method_name: method_name)
        end
      end
    end
  end
end
