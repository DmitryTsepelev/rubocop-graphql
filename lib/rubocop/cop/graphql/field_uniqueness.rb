# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # This cop detects duplicate field definitions within
      # the same type
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
      #   # bad
      #
      #   class UserType < BaseType
      #     field :name, String, null: true
      #     field :phone, String, null: true
      #     field :phone, String, null: true do
      #       argument :something, String, required: false
      #     end
      #   end
      #
      class FieldUniqueness < Base
        MSG = "Field names should only be defined once per type. "\
              "Field `%<current>s` is duplicated."

        def on_class(node)
          field_names = Set.new

          field_declarations(node).each do |current|
            current_field_name = field_name(current)

            unless field_names.include?(current_field_name)
              field_names.add(current_field_name)
              next
            end

            register_offense(current)
          end
        end

        private

        def register_offense(current)
          message = format(
            self.class::MSG,
            current: field_name(current)
          )

          add_offense(current, message: message)
        end

        def field_name(node)
          node.first_argument.value.to_s
        end

        def_node_search :field_declarations, <<~PATTERN
          {
            (send nil? :field (:sym _) ...)
          }
        PATTERN
      end
    end
  end
end
