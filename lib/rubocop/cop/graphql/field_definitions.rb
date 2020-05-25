# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # This cop checks consistency of field definitions
      #
      # EnforcedStyle supports two modes:
      #
      # `group_definitions` : all field definitions should be grouped together.
      #
      # `define_resolver_after_definition` : if resolver method exists it should
      # be defined right after the field definition.
      #
      # @example EnforcedStyle: group_definitions (default)
      #   # good
      #
      #   class UserType < BaseType
      #     field :first_name, String, null: true
      #     field :last_name, String, null: true
      #
      #     def first_name
      #       object.contact_data.first_name
      #     end
      #
      #     def last_name
      #       object.contact_data.last_name
      #     end
      #   end
      #
      # @example EnforcedStyle: define_resolver_after_definition
      #   # good
      #
      #   class UserType < BaseType
      #     field :first_name, String, null: true
      #
      #     def first_name
      #       object.contact_data.first_name
      #     end
      #
      #     field :last_name, String, null: true
      #
      #     def last_name
      #       object.contact_data.last_name
      #     end
      #   end
      class FieldDefinitions < Cop
        include ConfigurableEnforcedStyle
        include RuboCop::GraphQL::NodePattern

        def_node_matcher :field_kwargs, <<~PATTERN
          (send nil? :field
            ...
            (hash
              $...
            )
          )
        PATTERN

        def_node_matcher :class_body, <<~PATTERN
          (class ... (begin $...))
        PATTERN

        def on_send(node)
          return if !field_definition?(node) || style != :define_resolver_after_definition

          field = RuboCop::GraphQL::Field.new(node)
          check_resolver_is_defined_after_definition(field)
        end

        def on_class(node)
          return if style != :group_definitions

          body = class_body(node)
          check_grouped_field_declarations(body) if body
        end

        private

        GROUP_DEFS_MSG = "Group all field definitions together."

        def check_grouped_field_declarations(body)
          fields = body.select { |node| field_definition?(node) || field_definition_with_body?(node) }

          first_field = fields.first

          fields.each_with_index do |node, idx|
            next if node.sibling_index == first_field.sibling_index + idx

            add_offense(node, message: GROUP_DEFS_MSG)
          end
        end

        RESOLVER_AFTER_FIELD_MSG = "Define resolver method after field definition."

        def check_resolver_is_defined_after_definition(field)
          return if field.resolver || field.method || field.hash_key

          root = field.ancestors.find { |parent| root_node?(parent) }
          method_definition = find_method_definition(root, field.resolver_method_name)
          return unless method_definition

          field_sibling_index = if field_definition_with_body?(field.parent)
            field.parent.sibling_index
          else
            field.sibling_index
          end

          return if method_definition.sibling_index - field_sibling_index == 1

          add_offense(field.node, message: RESOLVER_AFTER_FIELD_MSG)
        end

        def find_method_definition(root, method_name)
          class_body(root).find { |node| node.def_type? && node.method_name == method_name }
        end

        def root_node?(node)
          node.parent.nil? || root_with_siblings?(node.parent)
        end

        def root_with_siblings?(node)
          node.begin_type? && node.parent.nil?
        end
      end
    end
  end
end
