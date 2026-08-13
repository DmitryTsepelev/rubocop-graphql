# frozen_string_literal: true

module RuboCop
  module GraphQL
    class Argument
      extend RuboCop::NodePattern::Macros

      # @!method argument_description(node)
      def_node_matcher :argument_description, <<~PATTERN
        (send nil? :argument _ _ (:str $_) ...)
      PATTERN

      # @!method argument_name(node)
      def_node_matcher :argument_name, <<~PATTERN
        (send nil? :argument (:sym $_) ...)
      PATTERN

      # @!method argument_as(node)
      def_node_matcher :argument_as, <<~PATTERN
        (pair (sym :as) (sym $_))
      PATTERN

      # @!method argument_required(node)
      def_node_matcher :argument_required, <<~PATTERN
        (pair (sym :required) $_)
      PATTERN

      attr_reader :node

      def initialize(node)
        @node = node
      end

      def name
        @name ||= argument_name(@node)
      end

      def as
        @as ||= argument_as(kwargs.as)
      end

      # The keyword this argument is passed as to #resolve and friends. `as:` wins when both
      # are given, matching graphql-ruby's `kwargs[:as] ||= inferred_arg_name`.
      def keyword
        return as if kwargs.as
        return inferred_keyword if kwargs.loads

        name
      end

      # `required: false` is the only value that lets graphql-ruby omit the keyword:
      # `required: :nullable` still demands the argument be present, though it may be null.
      def optional?
        required_node = kwargs.required
        return false unless required_node

        argument_required(required_node)&.false_type? || false
      end

      # A configured default is always passed, even when the client omits the argument.
      def default_value?
        !kwargs.default_value.nil?
      end

      def description
        @description ||= argument_description(@node) || kwargs.description || block.description
      end

      def kwargs
        @kwargs ||= Argument::Kwargs.new(@node)
      end

      def block
        @block ||= Argument::Block.new(@node.parent)
      end

      private

      # Mirrors graphql-ruby: a `loads:` argument named `foo_id` arrives as `foo:`, and one
      # named `foo_ids` arrives as `foos:`.
      def inferred_keyword
        name_as_string = name.to_s

        case name_as_string
        when /_id$/
          name_as_string.sub(/_id$/, "").to_sym
        when /_ids$/
          name_as_string.sub(/_ids$/, "").sub(/([^s])$/, "\\1s").to_sym
        else
          name
        end
      end
    end
  end
end
