# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop detects method definitions that are never called because
      #  the field's effective `resolver_method` points somewhere else.
      #
      #  graphql-ruby only ever calls a single method on the type instance:
      #  the field's `resolver_method` (which is the resolver class's own
      #  method when `resolver:` is set, the explicit `resolver_method:`
      #  value when given, or the field name otherwise). Any other
      #  same-named method left on the type is unreachable:
      #
      #  - When `resolver:` is set, the resolver class handles resolution
      #    entirely, so neither the field name, `resolver_method:`, nor
      #    `method:` (if also given) is ever dispatched to a method on the type.
      #  - When only `resolver_method:` is set, that name is the one
      #    actually called -- a leftover method matching the plain field
      #    name is never reached.
      #
      # @example
      #   # good
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, resolver: Resolvers::AuthorResolver
      #   end
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, String, null: true, resolver_method: :fetch_author
      #
      #     def fetch_author
      #       object.author
      #     end
      #   end
      #
      #   # bad
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, resolver: Resolvers::AuthorResolver
      #
      #     def author
      #       object.author
      #     end
      #   end
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, String, null: true, resolver_method: :fetch_author
      #
      #     def author
      #       object.author
      #     end
      #
      #     def fetch_author
      #       object.author
      #     end
      #   end
      #
      class MethodShadowedByResolverMethod < Base
        include RuboCop::GraphQL::NodePattern

        RESOLVER_MSG = "Remove this method, it is never called: `resolver: %<resolver>s` " \
                       "resolves this field instead."
        RESOLVER_METHOD_MSG = "Remove this method, it is never called: " \
                              "`resolver_method: :%<resolver_method>s` is called instead."
        RESTRICT_ON_SEND = %i[field].freeze

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)

          if field.kwargs.resolver
            register_resolver_offenses(field)
          else
            register_resolver_method_offense(field)
          end
        end

        private

        # Neither `resolver_method:` nor `method:` has any effect once `resolver:` is
        # set (graphql-ruby always calls the resolver class's own resolver_method), so
        # a method matching the field's own name, an explicit `resolver_method:`, or
        # an explicit `method:` is equally unreachable.
        def register_resolver_offenses(field)
          resolver_source = field.kwargs.resolver.value.source
          message = format(RESOLVER_MSG, resolver: resolver_source)

          candidate_names = [
            field.name, field.kwargs.resolver_method_name, method_kwarg_name(field)
          ].compact.uniq
          candidate_names.each do |method_name|
            shadowed_method = field.schema_member.find_method_definition(method_name)
            add_offense(shadowed_method.loc.name, message: message) if shadowed_method
          end
        end

        # The `resolver_method:`-named method is the one actually called; only a
        # leftover method matching the plain field name is dead.
        def register_resolver_method_offense(field)
          resolver_method_kwarg = field.kwargs.resolver_method_name
          return unless resolver_method_kwarg && resolver_method_kwarg != field.name

          shadowed_method = field.schema_member.find_method_definition(field.name)
          return unless shadowed_method

          message = format(RESOLVER_METHOD_MSG, resolver_method: resolver_method_kwarg)
          add_offense(shadowed_method.loc.name, message: message)
        end

        def method_kwarg_name(field)
          pair = field.kwargs.method
          return nil unless pair

          value_node = pair.value
          value_node.value if value_node.sym_type?
        end
      end
    end
  end
end
