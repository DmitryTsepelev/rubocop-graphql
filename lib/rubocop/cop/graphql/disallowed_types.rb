# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Flags field and argument types the project has decided not to expose, with a message
      # explaining what to use instead.
      #
      # Every schema accumulates types that are still resolvable but shouldn't be reached for
      # in new code: a scalar kept alive only for backwards compatibility, a type that predates
      # a better one, or a builtin whose semantics don't fit the domain -- `Float` for money,
      # say, where the serialization loses precision. The convention is usually documented and
      # then re-litigated in review; this makes it fail the build instead.
      #
      # Nothing is disallowed by default: the cop is inert until `Types` is configured.
      #
      # A configured name matches the written constant exactly, or as a trailing segment of it,
      # so `Float` covers `Float`, `Types::Float` and `GraphQL::Types::Float`. Configure
      # `GraphQL::Types::Float` instead to match only the fully qualified form.
      #
      # List types are unwrapped, so `[Float]` and `[Float, null: true]` are flagged too, and
      # both the positional type and the `type:` keyword are checked.
      #
      # @example Types: {'Float' => 'Use Types::Decimal, which serializes as a string.'}
      #   # bad
      #   field :amount, Float, null: false
      #   argument :amount, Float, required: true
      #   field :amounts, [Float], null: false
      #   field :amount, type: Float, null: false
      #
      #   # good
      #   field :amount, Types::Decimal, null: false
      #   argument :amount, Types::Decimal, required: true
      #
      # @example Types: {'Types::LegacyDate' => 'Use GraphQL::Types::ISO8601Date.'}
      #   # bad
      #   field :starts_on, Types::LegacyDate, null: false
      #
      #   # good
      #   field :starts_on, GraphQL::Types::ISO8601Date, null: false
      #
      class DisallowedTypes < Base
        MSG = "`%<type>s` is not allowed as a field or argument type."
        MSG_WITH_REASON = "`%<type>s` is not allowed as a field or argument type. %<reason>s"

        RESTRICT_ON_SEND = %i[field argument].freeze

        def on_send(node)
          return if disallowed_types.empty?
          return unless type_declaration?(node)

          each_type_const(node) do |const_node|
            configured_name = disallowed_name_for(const_node)
            next unless configured_name

            add_offense(const_node, message: message_for(configured_name))
          end
        end

        private

        def disallowed_types
          @disallowed_types ||= (cop_config["Types"] || {}).transform_keys(&:to_s)
        end

        def message_for(configured_name)
          reason = disallowed_types[configured_name].to_s.strip

          if reason.empty?
            format(MSG, type: configured_name)
          else
            format(MSG_WITH_REASON, type: configured_name, reason: reason)
          end
        end

        def disallowed_name_for(const_node)
          written_name = const_node.const_name

          disallowed_types.keys.find do |configured_name|
            written_name == configured_name || written_name.end_with?("::#{configured_name}")
          end
        end

        # Yields the constants a `field`/`argument` call names as its type: the positional type
        # and the `type:` keyword, each unwrapped through any list nesting.
        def each_type_const(send_node, &block)
          each_const_in(send_node.arguments[1], &block)
          each_const_in(type_kwarg(send_node), &block)
        end

        def each_const_in(node, &block)
          return unless node

          case node.type
          when :const then yield node
          when :array then node.children.each { |child| each_const_in(child, &block) }
          end
        end

        # An explicit receiver means this is some other `field`/`argument` method, not the DSL.
        #
        # @!method type_declaration?(node)
        def_node_matcher :type_declaration?, <<~PATTERN
          (send nil? {:field :argument} ...)
        PATTERN

        # @!method type_kwarg(node)
        def_node_matcher :type_kwarg, <<~PATTERN
          (send nil? {:field :argument} ... (hash <(pair (sym :type) $_) ...>))
        PATTERN
      end
    end
  end
end
