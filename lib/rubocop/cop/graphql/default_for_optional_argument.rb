# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Optional arguments should have a default value in the resolver signature.
      #
      # When the client omits an argument declared `required: false`, graphql-ruby leaves it
      # out of the keyword arguments entirely, so a required keyword raises
      # `ArgumentError: missing keyword`. Giving the keyword a default value is what makes the
      # argument actually optional at runtime.
      #
      # Arguments declared with a `default_value:` are always passed, so they are not reported.
      # Neither is `required: :nullable`, which still demands the argument be present.
      #
      # Both class-level arguments (checked against `#resolve` and `#authorized?`) and
      # arguments defined inside a field block (checked against that field's resolver method)
      # are covered.
      #
      # @example
      #   # bad
      #
      #   class SomeResolver < Resolvers::Base
      #     argument :name, String, required: false
      #
      #     def resolve(name:); end
      #   end
      #
      #   # good
      #
      #   class SomeResolver < Resolvers::Base
      #     argument :name, String, required: false
      #
      #     def resolve(name: nil); end
      #   end
      #
      #   # good - a default value means the keyword is always passed
      #
      #   class SomeResolver < Resolvers::Base
      #     argument :name, String, required: false, default_value: "anonymous"
      #
      #     def resolve(name:); end
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseObject
      #     field :posts, [PostType], null: false do
      #       argument :limit, Integer, required: false
      #     end
      #
      #     def posts(limit:); end
      #   end
      #
      #   # good
      #
      #   class UserType < BaseObject
      #     field :posts, [PostType], null: false do
      #       argument :limit, Integer, required: false
      #     end
      #
      #     def posts(limit: 10); end
      #   end
      #
      class DefaultForOptionalArgument < Base
        MSG = "Optional argument `%<keyword>s` has no default value in `%<method>s`, so " \
              "omitting it raises ArgumentError."

        RESOLVER_METHODS = %i[resolve authorized?].freeze

        def on_class(node)
          body = node.body
          return unless body

          defs = definitions_in(node)
          return if defs.empty?

          check_class_arguments(node, defs)
          check_field_arguments(node, defs)
        end

        private

        def check_class_arguments(class_node, defs)
          keywords = optional_keywords(class_arguments(class_node))
          return if keywords.empty?

          RESOLVER_METHODS.each do |method_name|
            check_signature(defs[method_name], keywords)
          end
        end

        def check_field_arguments(class_node, defs)
          field_blocks(class_node).each do |block_node|
            field = RuboCop::GraphQL::Field.new(block_node.send_node)
            next if field.kwargs.resolver

            keywords = optional_keywords(block_arguments(block_node))
            next if keywords.empty?

            check_signature(defs[field.resolver_method_name.to_sym], keywords)
          end
        end

        def check_signature(def_node, keywords)
          return unless def_node

          def_node.arguments.each do |arg_node|
            next unless arg_node.kwarg_type?
            next unless keywords.include?(arg_node.node_parts[0])

            add_offense(
              arg_node,
              message: format(MSG, keyword: arg_node.node_parts[0], method: def_node.method_name)
            )
          end
        end

        # Keywords of arguments that graphql-ruby may leave out of the resolver call.
        def optional_keywords(argument_nodes)
          argument_nodes.filter_map do |argument_node|
            argument = RuboCop::GraphQL::Argument.new(argument_node)
            argument.keyword if argument.optional? && !argument.default_value?
          end.to_set
        end

        # `def`s owned by this class, keyed by name. A nested class gets its own `on_class`.
        def definitions_in(class_node)
          each_in_scope(class_node.body, :def).each_with_object({}) do |def_node, defs|
            defs[def_node.method_name] ||= def_node
          end
        end

        # Class-level `argument` calls: the walk stops at blocks, so field-block arguments
        # (handled separately, against a different method) are not picked up here.
        def class_arguments(class_node)
          each_in_scope(class_node.body, :send, stop_at_block: true).select do |send_node|
            argument_declaration?(send_node)
          end
        end

        def block_arguments(block_node)
          body = block_node.body
          return [] unless body

          each_in_scope(body, :send).select { |send_node| argument_declaration?(send_node) }
        end

        def field_blocks(class_node)
          each_in_scope(class_node.body, :block).select do |block_node|
            field_declaration?(block_node.send_node)
          end
        end

        # Collects nodes of `type` without descending into a nested class or module body.
        # With `stop_at_block`, a block contributes only the call that opens it, so a nested
        # `field ... do ... end` keeps its own arguments out of the enclosing scope.
        def each_in_scope(node, type, stop_at_block: false, found: [])
          found << node if node.type == type
          return found if node.type?(:class, :module, :sclass)

          children =
            if stop_at_block && node.type?(:any_block)
              [node.send_node]
            else
              node.each_child_node
            end

          children.each do |child|
            each_in_scope(child, type, stop_at_block: stop_at_block, found: found)
          end
          found
        end

        # @!method argument_declaration?(node)
        def_node_matcher :argument_declaration?, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN

        # @!method field_declaration?(node)
        def_node_matcher :field_declaration?, <<~PATTERN
          (send nil? :field (:sym _) ...)
        PATTERN
      end
    end
  end
end
