# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # A non-null field should not have a resolver whose Sorbet signature returns a nilable
      # type. The two disagree: the schema promises a value, the signature admits `nil`, and
      # graphql-ruby raises an invalid-null error for every object that resolves to `nil`.
      #
      # Sorbet cannot catch this, because the field declaration is not part of the signature.
      # Only the crashing direction is reported: a nullable field with a non-nilable resolver
      # is merely imprecise, not broken.
      #
      # Codebases without Sorbet signatures never trigger this cop.
      #
      # @example
      #   # bad
      #
      #   class UserType < BaseObject
      #     field :name, String, null: false
      #
      #     sig { override.returns(T.nilable(String)) }
      #     def name
      #       object.name
      #     end
      #   end
      #
      #   # good - the schema admits what the resolver may return
      #
      #   class UserType < BaseObject
      #     field :name, String, null: true
      #
      #     sig { override.returns(T.nilable(String)) }
      #     def name
      #       object.name
      #     end
      #   end
      #
      #   # good - the resolver guarantees what the schema promises
      #
      #   class UserType < BaseObject
      #     field :name, String, null: false
      #
      #     sig { override.returns(String) }
      #     def name
      #       object.name || "anonymous"
      #     end
      #   end
      #
      class NullabilityMismatch < Base
        include RuboCop::GraphQL::Sorbet

        MSG = "Field `%<field>s` is `null: false` but its resolver signature returns a " \
              "nilable type, so a nil resolves to an invalid null error."

        def on_class(node)
          non_null_fields = collect_non_null_fields(node)
          return if non_null_fields.empty?

          node.each_descendant(:def) do |def_node|
            next unless owned_by?(def_node, node)

            field_node = non_null_fields[def_node.method_name]
            next unless field_node && nilable_signature?(def_node)

            field_name = RuboCop::GraphQL::Field.new(field_node).name
            add_offense(field_node, message: format(MSG, field: field_name))
          end
        end
        alias on_module on_class

        private

        # Non-null fields owned by this type, keyed by the method that resolves them. Fields
        # handed off to a `resolver:` class are resolved elsewhere, so they are skipped.
        def collect_non_null_fields(node)
          fields = {}

          node.each_descendant(:send) do |send_node|
            next unless non_null_field?(send_node) && owned_by?(send_node, node)

            field = RuboCop::GraphQL::Field.new(send_node)
            next if field.kwargs.resolver

            fields[field.resolver_method_name.to_sym] ||= send_node
          end

          fields
        end

        def nilable_signature?(def_node)
          signature = sorbet_signature_for(def_node)
          return false unless signature

          signature.each_descendant(:send).any? do |send_node|
            send_node.method?(:returns) && nilable_type?(send_node.first_argument)
          end
        end

        # Only the outermost type counts. `T::Array[T.nilable(String)]` is a non-null list of
        # nullable items, which pairs correctly with a `null: false` field.
        def nilable_type?(node)
          return false unless node
          return true if t_nilable?(node)

          Array(t_any_types(node)).any? { |type| nil_class?(type) }
        end

        # True when `node`'s nearest enclosing class or module is `owner`, so that a nested
        # type's fields and methods are not attributed to the one around it.
        def owned_by?(node, owner)
          node.each_ancestor(:class, :module).first == owner
        end

        # @!method non_null_field?(node)
        def_node_matcher :non_null_field?, <<~PATTERN
          (send nil? :field (sym _) ... (hash <(pair (sym :null) (false)) ...>))
        PATTERN

        # @!method t_nilable?(node)
        def_node_matcher :t_nilable?, <<~PATTERN
          (send (const {nil? cbase} :T) :nilable ...)
        PATTERN

        # @!method t_any_types(node)
        def_node_matcher :t_any_types, <<~PATTERN
          (send (const {nil? cbase} :T) :any $...)
        PATTERN

        # @!method nil_class?(node)
        def_node_matcher :nil_class?, <<~PATTERN
          (const {nil? cbase} :NilClass)
        PATTERN
      end
    end
  end
end
