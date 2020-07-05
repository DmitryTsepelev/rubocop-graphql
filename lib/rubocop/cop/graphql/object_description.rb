# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks if a type (object, input, interface, scalar, union, mutation, subscription, and resolver) has a description.
      #
      # @example
      #   # good
      #
      #   class Types::UserType < Types::BaseObject
      #     description "Represents application user"
      #     # ...
      #   end
      #
      #   # bad
      #
      #   class Types::UserType < Types::BaseObject
      #     # ...
      #   end
      #
      class ObjectDescription < Cop
        include RuboCop::GraphQL::NodePattern

        MSG = "Missing type description"

        def_node_matcher :has_i18n_description?, <<~PATTERN
          (send nil? :description (send (const nil? :I18n) :t ...))
        PATTERN

        def_node_matcher :has_string_description?, <<~PATTERN
          (send nil? :description (:str $_))
        PATTERN

        def_node_matcher :interface?, <<~PATTERN
          (send nil? :include (const ...))
        PATTERN

        def on_class(node)
          return if child_nodes(node).find { |child_node| has_description?(child_node) }

          add_offense(node.identifier)
        end

        def on_module(node)
          return if child_nodes(node).none? { |child_node| interface?(child_node) }

          add_offense(node.identifier) if child_nodes(node).none? { |child_node| has_description?(child_node) }
        end

        private

        def has_description?(node)
          has_i18n_description?(node) || has_string_description?(node)
        end

        def child_nodes(node)
          if node.body.instance_of? RuboCop::AST::Node
            node.body.child_nodes
          else
            node.child_nodes
          end
        end
      end
    end
  end
end
