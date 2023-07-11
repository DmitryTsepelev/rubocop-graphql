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
      # This cop also checks the `can_can_action` or `pundit_role` methods that
      # can be used as part of the Ruby GraphQL Pro.
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
      #   # good
      #
      #   class UserType < BaseType
      #     implements GraphQL::Types::Relay::Node
      #
      #     pundit_role :staff
      #
      #     field :uuid, ID, null: false
      #   end
      #
      #   # good
      #
      #   class UserType < BaseType
      #     implements GraphQL::Types::Relay::Node
      #
      #     can_can_action :staff
      #
      #     field :uuid, ID, null: false
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

        # @!method has_can_can_action?(node)
        def_node_matcher :has_can_can_action?, <<~PATTERN
          `(send nil? :can_can_action sym_type?)
        PATTERN

        # @!method has_pundit_role?(node)
        def_node_matcher :has_pundit_role?, <<~PATTERN
          `(send nil? :pundit_role sym_type?)
        PATTERN

        # @!method has_authorized_method?(node)
        def_node_matcher :has_authorized_method?, <<~PATTERN
          {`(:defs (:self) :authorized? ...) | `(:sclass (:self) `(:def :authorized? ...))}
        PATTERN

        def on_class(node)
          return if ignored_class?(parent_class(node))

          if implements_node_type?(node) && !has_authorized_method?(node) && !has_can_can_action?(node) && !has_pundit_role?(node)
            add_offense(node)
          end
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
