# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop detects `resolver_method:` or `method:` options that have no
      #  effect, either because:
      #
      #  - the same field also sets `resolver:` -- graphql-ruby always calls
      #    the resolver class's own resolver_method once `resolver:` is set,
      #    silently ignoring both `resolver_method:` and `method:` regardless
      #    of whether a method by either name exists; or
      #  - a method matching the field's own plain name is also defined on the
      #    type -- that method is checked (and wins) before `method:` is ever
      #    considered, since `method:` is only consulted as a fallback when no
      #    such method exists. This only applies to `method:`: `resolver_method:`
      #    redirects which name is checked instead of competing with it, so it
      #    can't be shadowed by a same-named `def` the way `method:` can.
      #
      # @example
      #   # good
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, resolver: Resolvers::AuthorResolver
      #   end
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, String, null: true, method: :ghostwriter
      #   end
      #
      #   # bad
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, resolver: Resolvers::AuthorResolver, resolver_method: :fetch_author
      #   end
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, resolver: Resolvers::AuthorResolver, method: :ghostwriter
      #   end
      #
      #   class Types::PostType < Types::BaseObject
      #     field :author, String, null: true, method: :ghostwriter
      #
      #     def author
      #       object.author
      #     end
      #   end
      #
      class UselessMethodOption < Base
        include RuboCop::GraphQL::NodePattern

        RESOLVER_MSG = "Remove `%<option>s:`, it has no effect: `resolver: %<resolver>s` " \
                       "always takes precedence."
        DEF_MSG = "Remove `method:`, it has no effect: `def %<field_name>s` on the type " \
                  "always takes precedence."
        RESTRICT_ON_SEND = %i[field].freeze

        # @!method resolver_method_pair(node)
        def_node_search :resolver_method_pair, "(pair (sym :resolver_method) ...)"

        # @!method method_pair(node)
        def_node_search :method_pair, "(pair (sym :method) ...)"

        def on_send(node)
          return unless field_definition?(node)

          field = RuboCop::GraphQL::Field.new(node)

          if field.kwargs.resolver
            register_resolver_offenses(node, field)
          else
            register_method_shadowed_by_def_offense(node, field)
          end
        end

        private

        def register_resolver_offenses(node, field)
          resolver_source = field.kwargs.resolver.value.source

          [resolver_method_pair(node).first, method_pair(node).first].compact.each do |pair|
            message = format(RESOLVER_MSG, option: pair.key.value, resolver: resolver_source)
            add_offense(pair, message: message)
          end
        end

        def register_method_shadowed_by_def_offense(node, field)
          pair = method_pair(node).first
          return unless pair

          shadowed_def = field.schema_member.find_method_definition(field.name)
          return unless shadowed_def

          message = format(DEF_MSG, field_name: field.name)
          add_offense(pair, message: message)
        end
      end
    end
  end
end
