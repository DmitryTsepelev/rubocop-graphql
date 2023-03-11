# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Detects types that implement Node interface and not have `.authorized?` check.
      # Such types can be fetched by ID and therefore should have type level check to
      # avoid accidental information exposure.
      #
      # @example
      #   # good
      #
      #   class UserType < BaseType
      #     implements GraphQL::Types::Relay::Node
      #
      #     field :uuid, ID, null: false
      #
      #     def self.authorized?(object, context)
      #       super && object.owner == context[:viewer]
      #     end
      #   end
      #
      #   # good
      #
      #   class UserType < BaseType
      #     implements GraphQL::Types::Relay::Node
      #
      #     field :uuid, ID, null: false
      #
      #     class << self
      #       def authorized?(object, context)
      #         super && object.owner == context[:viewer]
      #       end
      #     end
      #   end
      #
      #   # bad
      #
      #   class UserType < BaseType
      #     implements GraphQL::Types::Relay::Node
      #
      #     field :uuid, ID, null: false
      #   end
      #
      class NotAuthorizedNodeType < Base
        MSG = ".authorized? should be defined for types implementing Node interface."

        # @!method implements_node_type?(node)
        def_node_matcher :implements_node_type?, <<~PATTERN
          `(send nil? :implements
            (const
              (const
                (const
                  (const nil? :GraphQL) :Types) :Relay) :Node))
        PATTERN

        # @!method has_authorized_method?(node)
        def_node_matcher :has_authorized_method?, <<~PATTERN
          {`(:defs (:self) :authorized? ...) | `(:sclass (:self) `(:def :authorized? ...))}
        PATTERN

        def on_class(node)
          add_offense(node) if implements_node_type?(node) && !has_authorized_method?(node)
        end
      end
    end
  end
end
