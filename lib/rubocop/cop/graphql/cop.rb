# frozen_string_literal: true

module RuboCop
  # Inspied by https://github.com/rubocop-hq/rubocop-rspec/blob/3a2088f79737e2e8e0e21482783f7d61411bf021/lib/rubocop/cop/rspec/cop.rb
  module Cop
    WorkaroundGraphqlCop = Cop.dup

    # Clone of the the normal RuboCop::Cop::Cop class so we can rewrite
    # the inherited method without breaking functionality
    class WorkaroundGraphqlCop
      # Remove the Cop.inherited method to be a noop. Our RSpec::Cop
      # class will invoke the inherited hook instead
      class << self
        undef inherited
        def inherited(*); end # rubocop:disable Lint/MissingSuper
      end

      # Special case `Module#<` so that the rspec support rubocop exports
      # is compatible with our subclass
      def self.<(other)
        other.equal?(RuboCop::Cop::Cop) || super
      end
    end
    private_constant(:WorkaroundGraphqlCop)

    module GraphQL
      # @abstract parent class to graphql-ruby cops
      #
      # The criteria for whether rubocop-rspec analyzes a certain ruby file
      # is configured via `AllCops/GraphQL`. For example, if you want to
      # customize your project to scan all files within a `graph/` directory
      # then you could add this to your configuration:
      #
      # @example configuring analyzed paths
      #
      #   AllCops:
      #     GraphQL:
      #       Patterns:
      #       - '(?:^|/)graph/'
      class Cop < WorkaroundGraphqlCop
        DEFAULT_CONFIGURATION =
          RuboCop::GraphQL::CONFIG.fetch("AllCops").fetch("GraphQL")

        DEFAULT_PATTERN_RE = Regexp.union(
          DEFAULT_CONFIGURATION.fetch("Patterns")
                               .map(&Regexp.public_method(:new))
        )

        # Invoke the original inherited hook so our cops are recognized
        def self.inherited(subclass)  # rubocop:disable Lint/MissingSuper
          RuboCop::Cop::Cop.inherited(subclass)
        end

        def relevant_file?(file)
          relevant_rubocop_graphql_file?(file) && super
        end

        private

        def relevant_rubocop_graphql_file?(file)
          graphql_pattern =~ file
        end

        def graphql_pattern
          if rspec_graphql_config?
            Regexp.union(rspec_graphql_config.map(&Regexp.public_method(:new)))
          else
            DEFAULT_PATTERN_RE
          end
        end

        def all_cops_config
          config
            .for_all_cops
        end

        def rspec_graphql_config?
          return unless all_cops_config.key?("GraphQL")

          all_cops_config.fetch("GraphQL").key?("Patterns")
        end

        def rspec_graphql_config
          all_cops_config
            .fetch("GraphQL", DEFAULT_CONFIGURATION)
            .fetch("Patterns")
        end
      end
    end
  end
end
