# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks whether field names are snake_case.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     field :first_name, String, null: true
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     field :firstName, String, null: true
      #   end
      #
      class FieldName < Base
        extend AutoCorrector
        include RuboCop::GraphQL::NodePattern

        using RuboCop::GraphQL::Ext::SnakeCase

        MSG = "Use snake_case for field names"

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)
          return if field.name.snake_case?

          add_offense(node) do |corrector|
            rename_field_name(corrector, field, node)
          end
        end

        private

        def rename_field_name(corrector, field, node)
          name_field = field.name.to_s
          new_line = node.source.sub(name_field, underscore(name_field))
          corrector.replace(node, new_line)
        end

        # This method was extracted from activesupport in Rails:
        # https://github.com/rails/rails/blob/8dab534ca81dd32c6a83ac03596a1feb7ddaaca7/activesupport/lib/active_support/inflector/methods.rb#L96

        def underscore(camel_cased_word)
          regex = /(?:(?<=([A-Za-z\d]))|\b)((?=a)b)(?=\b|[^a-z])/
          return camel_cased_word.to_s unless /[A-Z-]|::/.match?(camel_cased_word)

          word = camel_cased_word.to_s.gsub("::", "/")
          word.gsub!(regex) { "#{Regexp.last_match(1) && '_'}#{Regexp.last_match(2).downcase}" }
          word.gsub!(/([A-Z\d]+)(?=[A-Z][a-z])|([a-z\d])(?=[A-Z])/) do
            (Regexp.last_match(1) || Regexp.last_match(2)) << "_"
          end
          word.tr!("-", "_")
          word.downcase!
          word
        end
      end
    end
  end
end
