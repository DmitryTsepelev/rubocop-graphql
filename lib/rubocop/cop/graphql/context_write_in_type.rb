# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Detects writes to the `context` object within GraphQL types.
      # Writing to `context` mutates shared state across the query execution,
      # which can lead to unexpected behavior and makes code harder to reason about.
      #
      # This cop is disabled by default.
      #
      # @example
      #   # bad
      #   class UserType < BaseType
      #     field :name, String, null: false
      #
      #     def name
      #       context[:current_user] = object.user
      #       object.name
      #     end
      #   end
      #
      #   # bad
      #   class UserType < BaseType
      #     field :name, String, null: false
      #
      #     def name
      #       context.merge!(current_user: object.user)
      #       object.name
      #     end
      #   end
      #
      #   # good
      #   class UserType < BaseType
      #     field :name, String, null: false
      #
      #     def name
      #       viewer = context[:current_user]
      #       object.name
      #     end
      #   end
      #
      class ContextWriteInType < Base
        MSG = "Avoid writing to `context` in GraphQL types. Mutating shared state can lead " \
              "to unexpected behavior."

        RESTRICT_ON_SEND = %i[[]= merge! store].freeze

        # @!method context_write?(node)
        def_node_matcher :context_write?, <<~PATTERN
          (send (send nil? :context) {:[]= :merge! :store} ...)
        PATTERN

        def on_send(node)
          return unless context_write?(node)

          add_offense(node)
        end
      end
    end
  end
end
