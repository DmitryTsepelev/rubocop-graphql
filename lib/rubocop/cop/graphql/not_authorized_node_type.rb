# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Detects types that implement Node interface and not have `.authorized?` check.
      # Such types can be fetched by ID and therefore should have type level check to
      # avoid accidental information exposure.
      #
      # If `.authorized?` is defined in a parent class, you can add parent to the "SafeBaseClasses"
      # to avoid offenses in children.
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

        # @!method class_name(node)
        def_node_matcher :class_name, <<~PATTERN
          (const nil? $_)
        PATTERN

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
          return if ignored_class?(parent_class(node))

          add_offense(node) if implements_node_type?(node) && !has_authorized_method?(node)
        end

        private

        def parent_class(node)
          node.child_nodes[1]
        end

        def ignored_class?(node)
          cop_config["SafeBaseClasses"].include?(String(class_name(node)))
        end
      end
    end
  end
end
