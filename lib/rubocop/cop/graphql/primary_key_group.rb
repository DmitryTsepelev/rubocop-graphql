# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      # Primary keys should be in their own individual groups.
      #
      # @example
      #   # good
      #
      #   class User < Users::BaseUser
      #     argument :id, ID, required: true
      #
      #     argument :email, String, required: false
      #     argument :name, String, required: false
      #   end
      #
      #   # good
      #
      #   class User < Users::BaseUser
      #     argument :id, ID, required: true
      #   end
      #
      #
      #   # good
      #
      #   class User < Users::BaseUser
      #     field :posts, PostType do
      #       argument :id, ID, required: true
      #
      #       argument :name, String, required: false
      #       argument :email, String, required: false
      #     end
      #   end
      #
      #   # bad
      #
      #   class User < Users::BaseUser
      #     argument :email, String, required: false
      #     argument :id, ID, required: true
      #     argument :name, String, required: false
      #   end
      #
      #   # bad
      #
      #   class User < Users::BaseUser
      #     argument :id, ID, required: true
      #     argument :email, String, required: false
      #     argument :name, String, required: false
      #   end
      #
      #   # bad
      #
      #   class User < Users::BaseUser
      #     field :posts, PostType do
      #       argument :email, String, required: false
      #       argument :id, ID, required: true
      #       argument :name, String, required: false
      #     end
      #   end
      #

      class PrimaryKeyGroup < Base
        extend AutoCorrector

        include RuboCop::GraphQL::SwapRange

        def on_class(node)
          nodes_arguments = pk_argument_declarations(node)
          check_nodes(nodes_arguments)
        end

        private

        MSG = "Primary keys should be in their own individual groups."
        METHODS_END = "end"
        # TODO: Make this constant configurable.
        PRIMARY_KEY_MATCHER = %i[id uuid].to_set.freeze

        def check_nodes(nodes)
          nodes.each do |argument|
            next if last_argument?(argument.last_line) && has_one_argument?(argument)

            if !next_line_empty?(argument.last_line)
              register_offense(argument)
            end
          end
        end

        def next_line_empty?(line)
          processed_source[line].blank?
        end

        def last_argument?(line)
          processed_source[line].strip == METHODS_END
        end

        def has_one_argument?(argument)
          argument_declarations(argument.parent).one?
        end

        def register_offense(argument)
          message = format(
            self.class::MSG,
            current: argument
          )

          first_argument = argument_declarations(argument.parent).first
          first_range = declaration(first_argument)
          current_range = declaration(argument)

          add_offense(argument, message: message) do |corrector|
            corrector.insert_before(first_range, "#{current_range.source}\n")
            corrector.remove(current_range)
          end
        end

        def_node_search :pk_argument_declarations, <<~PATTERN
          (send nil? :argument (:sym %PRIMARY_KEY_MATCHER) ...)
        PATTERN

        def_node_search :argument_declarations, <<~PATTERN
          (send nil? :argument (:sym _) ...)
        PATTERN
      end
    end
  end
end
