# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      #  This cop checks if a type (object, input, interface, scalar, union,
      #  mutation, subscription, and resolver) has a description.
      #
      #  Only classes that actually declare a GraphQL type are checked: those whose
      #  superclass resolves to a GraphQL base (`Object`, `InputObject`, `Union`,
      #  `Enum`, `Scalar`, or anything ending in `Mutation`, `Subscription` or
      #  `Resolver`), plus modules that `include` an `*Interface` base. Plain Ruby
      #  classes that happen to live alongside types - error classes, analyzers,
      #  validators, loaders, generators - are skipped, so they no longer need to be
      #  silenced one by one.
      #
      #  Two kinds of real type declarations are also skipped, because neither
      #  surfaces a description in the schema: abstract `Base*` types that other
      #  types inherit from, and (unless `IgnoreRootTypes` is disabled) the root
      #  operation types `Query`, `Mutation` and `Subscription`.
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
      # @example
      #   # good - not a GraphQL type, so no description is expected
      #
      #   class TrackingInfoNotAvailable < StandardError; end
      #   class UserLoader < GraphQL::Batch::Loader; end
      #
      # @example
      #   # good - abstract base and root operation types carry no description
      #
      #   class Types::BaseObject < GraphQL::Schema::Object; end
      #   class Types::Query < Types::BaseObject; end
      #
      # @example AdditionalTypeBases: [] (default)
      #   # good - `ApplicationType` is not a recognized GraphQL base, so this
      #   # class is not checked
      #
      #   class Types::UserType < ApplicationType
      #   end
      #
      # @example AdditionalTypeBases: ['ApplicationType']
      #   # bad - `ApplicationType` is now treated as a GraphQL base
      #
      #   class Types::UserType < ApplicationType
      #   end
      #
      class ObjectDescription < Base
        include RuboCop::GraphQL::DescriptionMethod

        MSG = "Missing type description"

        # Base class names that mark a GraphQL type when they match exactly, or with
        # a `Base` prefix (`GraphQL::Schema::Object`, `Types::BaseObject`).
        # Ambiguous words are deliberately not matched as suffixes, so a plain Ruby
        # `ValueObject` base is not mistaken for a GraphQL one. `Interface` is absent
        # on purpose: graphql-ruby interfaces are modules, so a *class* inheriting an
        # `*::Interface` constant is always some other abstract base.
        EXACT_BASES = %w[Object InputObject Union Enum Scalar].freeze

        # These read unambiguously as GraphQL even inside a longer name, so they are
        # matched as suffixes (`RelayClassicMutation`, `Base::PermissionedMutation`).
        SUFFIX_BASES = %w[Mutation Subscription Resolver].freeze

        # A base named exactly `Base` (`Resolvers::Base`) is only a GraphQL base when
        # it sits in a namespace that says so.
        GRAPHQL_NAMESPACES = %w[
          Types Mutations Subscriptions Resolvers Inputs Interfaces Unions Enums Scalars
        ].freeze

        # GraphQL reserves these names for the root operation types.
        ROOT_TYPE_NAMES = %w[Query Mutation Subscription].freeze

        # `Base`, or `Base` followed by another word - the naming convention for the
        # abstract types that other types inherit from (`BaseObject`, `BaseInterface`).
        ABSTRACT_BASE_NAME = /\ABase(?:[A-Z]|\z)/

        # Sorbet's `T` namespace is reserved, and `T::Enum` / `T::Struct` collide with
        # the base names above.
        SORBET_NAMESPACE = :T

        def on_class(node)
          return unless graphql_type_class?(node)
          return if exempt_type?(node)
          return if described_or_root_named?(node)

          add_offense(node.identifier)
        end

        def on_module(node)
          return if abstract_base?(node)
          return unless undescribed_interface_module?(node)

          add_offense(node.identifier)
        end

        private

        # Abstract bases and the root operation types are real GraphQL declarations,
        # but neither surfaces a description in the schema.
        def exempt_type?(node)
          return true if abstract_base?(node)

          ignore_root_types? && ROOT_TYPE_NAMES.include?(type_name(node))
        end

        def abstract_base?(node)
          ABSTRACT_BASE_NAME.match?(type_name(node))
        end

        def type_name(node)
          node.identifier.short_name.to_s
        end

        def graphql_type_class?(node)
          superclass = node.parent_class
          return false if superclass.nil? || !superclass.const_type?
          return false if superclass.namespace&.short_name == SORBET_NAMESPACE

          graphql_base?(superclass)
        end

        def graphql_base?(const_node)
          name = const_node.short_name.to_s
          return true if additional_type_bases.include?(name)
          return graphql_namespace?(const_node) if name == "Base"
          return true if SUFFIX_BASES.any? { |suffix| name.end_with?(suffix) }

          EXACT_BASES.include?(name.delete_prefix("Base"))
        end

        def graphql_namespace?(const_node)
          namespace = const_node.namespace
          return false if namespace.nil? || !namespace.const_type?

          GRAPHQL_NAMESPACES.include?(namespace.short_name.to_s)
        end

        # A method call with no explicit receiver (e.g. `description "..."`,
        # `include Foo`) - the shape of a GraphQL type DSL declaration.
        def bare_call?(node)
          node.send_type? && node.receiver.nil?
        end

        # Single pass over the module body: an interface module both `include`s an
        # `*Interface` base and (when compliant) declares a `description`.
        def undescribed_interface_module?(node)
          interface = false
          described = false

          body_nodes(node).each do |child|
            described ||= description_method_call?(child)
            interface ||= interface_include?(child)
          end

          interface && !described
        end

        def interface_include?(node)
          return false unless bare_call?(node) && node.method?(:include)

          arg = node.first_argument
          return false unless arg&.const_type?

          name = arg.short_name.to_s
          name.end_with?("Interface") || additional_type_bases.include?(name)
        end

        # Single pass over the class body: a `description` satisfies the cop, and a
        # `graphql_name "Query"` marks a root operation type declared under some
        # other class name, which is exempt like a class named `Query` itself.
        def described_or_root_named?(node)
          body_nodes(node).any? do |child|
            description_method_call?(child) || root_graphql_name?(child)
          end
        end

        def root_graphql_name?(node)
          return false unless ignore_root_types?
          return false unless bare_call?(node) && node.method?(:graphql_name)

          arg = node.first_argument
          return false unless arg&.str_type?

          ROOT_TYPE_NAMES.include?(arg.value)
        end

        def body_nodes(node)
          body = node.body
          return [] if body.nil?

          body.begin_type? ? body.child_nodes : [body]
        end

        def ignore_root_types?
          cop_config.fetch("IgnoreRootTypes", true)
        end

        def additional_type_bases
          @additional_type_bases ||= Array(cop_config["AdditionalTypeBases"])
        end
      end
    end
  end
end
