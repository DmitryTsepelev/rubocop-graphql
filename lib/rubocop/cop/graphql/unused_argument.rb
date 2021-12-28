# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Arguments should either be listed explicitly or **rest should be in the resolve signature.
      #
      # @example
      #   # good
      #
      #   class SomeResolver < Resolvers::Base
      #     argument :arg1, String, required: true
      #     argument :arg2, String, required: true
      #
      #     def resolve(arg1:, arg2:); end
      #   end
      #
      #   # good
      #
      #   class SomeResolver < Resolvers::Base
      #     argument :arg1, String, required: true
      #     argument :arg2, String, required: true
      #
      #     def resolve(arg1:, **rest); end
      #   end
      #
      #   # good
      #
      #   class SomeResolver < Resolvers::Base
      #     type SomeType, null: false
      #
      #     argument :arg1, String, required: true
      #     argument :arg2, String, required: true
      #
      #     def resolve(args); end
      #   end
      #
      #   # bad
      #
      #   class SomeResolver < Resolvers::Base
      #     type SomeType, null: false
      #
      #     argument :arg1, String, required: true
      #     argument :arg2, String, required: true
      #
      #     def resolve(arg1:); end
      #   end
      #
      #   # bad
      #
      #   class SomeResolver < Resolvers::Base
      #     type SomeType, null: false
      #
      #     argument :arg1, String, required: true
      #     argument :arg2, String, required: true
      #
      #     def resolve; end
      #   end
      #
      class UnusedArgument < Base
        extend AutoCorrector

        MSG = "Argument%<ending>s `%<unresolved_args>s` should be listed in the resolve signature."

        def on_class(node)
          resolve_method_node = find_resolve_method_node(node)
          return if resolve_method_node.nil? ||
                        resolve_method_node.arguments.any? { |arg| arg.arg_type? || arg.kwrestarg_type? }

          declared_arg_nodes = argument_declarations(node)
          return if declared_arg_nodes.empty?

          declared_args = declared_arg_nodes.map do |declared_arg_node|
            RuboCop::GraphQL::Argument.new(declared_arg_node)
          end

          unresolved_args = find_unresolved_args(resolve_method_node, declared_args)
          if unresolved_args.any?
            register_offense(resolve_method_node, unresolved_args)
          end
        end

        private

        def find_resolve_method_node(node)
          resolve_method_nodes = resolve_method_definition(node)
          return if resolve_method_nodes.empty?

          resolve_method_nodes.to_a.last
        end

        def find_unresolved_args(actual_resolve_method_node, declared_args)
          resolve_method_kwargs = actual_resolve_method_node.arguments.select(&:kwarg_type?).map {|node| node.node_parts[0] }.to_set
          declared_args.map(&:name).uniq.reject { |declared_arg| resolve_method_kwargs.include?(declared_arg) }
        end

        def register_offense(node, unresolved_args)
          unresolved_args_source = unresolved_args.map{|v| "#{v}:"}.join(', ')

          message = format(
            self.class::MSG,
            unresolved_args: unresolved_args_source,
            ending: unresolved_args.size == 1 ? '' : 's'
          )

          add_offense(node, message: message) do |corrector|
            if node.arguments?
              corrector.insert_after(arg_end(node.arguments.last), ", #{unresolved_args_source}")
            else
              corrector.insert_after(method_name(node), "(#{unresolved_args_source})")
            end
          end
        end

        def method_name(node)
          node.loc.keyword.end.resize(node.method_name.to_s.size + 1)
        end

        def arg_end(node)
          node.loc.expression.end
        end

        def_node_search :argument_declarations, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN

        def_node_search :resolve_method_definition, <<~PATTERN
          (def :resolve
            (args ...) ...)
        PATTERN
      end
    end
  end
end
