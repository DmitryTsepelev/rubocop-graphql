# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ObjectDescription, :config do
  context "when object" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Types::UserType < Types::BaseObject
            description "Represents application user"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description "Represents application " \
                          "user"
            end
          RUBY
        end
      end

      context "when description is multiline heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description <<~MSG
                Represents application
                user
              MSG
            end
          RUBY
        end
      end

      context "when description is a processed heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description <<-MSG.strip
                Represents application user
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description USER_TYPE_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a method call" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description t(:user_type)
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::UserType < Types::BaseObject
              description DESCRIPTION[:user_type]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Types::UserType < Types::BaseObject
                ^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when mutation" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Mutations::User::Create < Mutations::BaseMutation
            description "Creates a user"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Mutations::User::Create < Mutations::BaseMutation
              description "Creates a " \
                          "user"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Mutations::User::Create < Mutations::BaseMutation
              description <<~MSG
                Creates a user
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Mutations::User::Create < Mutations::BaseMutation
              description USER_CREATE_MUTATION_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Mutations::User::Create < Mutations::BaseMutation
              description DESCRIPTION[:user_create_mutation]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Mutations::User::Create < Mutations::BaseMutation
                ^^^^^^^^^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when subscription" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
            description "Subscribes to messages"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
              description "Subscribes to " \
                          "messages"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
              description <<~MSG
                Subscribes to messages
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
              description MESSAGE_WAS_POSTED_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
              description DESCRIPTION[:message_was_posted]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Subscriptions::MessageWasPosted < Subscriptions::BaseSubscription
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when resolver" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Resolvers::User < Resolvers::Base
            description "Returns the user"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Resolvers::User < Resolvers::Base
              description "Returns the " \
                          "user"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Resolvers::User < Resolvers::Base
              description <<~MSG
                Returns the user
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Resolvers::User < Resolvers::Base
              description USER_RESOLVER_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Resolvers::User < Resolvers::Base
              description DESCRIPTION[:user_resolver]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Resolvers::User < Resolvers::Base
                ^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when input" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Types::User::CreateInput < Types::BaseInputObject
            description "Attributes for creating a user"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::User::CreateInput < Types::BaseInputObject
              description "Attributes for creating a " \
                          "user"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::User::CreateInput < Types::BaseInputObject
              description <<~MSG
                Attributes for creating a user
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::User::CreateInput < Types::BaseInputObject
              description USER_CREATE_INPUT_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::User::CreateInput < Types::BaseInputObject
              description DESCRIPTION[:user_create_input]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Types::User::CreateInput < Types::BaseInputObject
                ^^^^^^^^^^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when interface" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          module Types::NodeInterface
            include Types::BaseInterface
            description "An object with an ID"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            module Types::NodeInterface
              include Types::BaseInterface
              description "An object with an " \
                          "ID"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            module Types::NodeInterface
              include Types::BaseInterface
              description <<~MSG
                An object with an ID
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            module Types::NodeInterface
              include Types::BaseInterface
              description NODE_INTERFACE_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            module Types::NodeInterface
              include Types::BaseInterface
              description DESCRIPTION[:base_interface]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          module Types::NodeInterface
                 ^^^^^^^^^^^^^^^^^^^^ Missing type description
            include Types::BaseInterface
          end
        RUBY
      end
    end
  end

  context "when scalar" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Types::Money < Types::BaseScalar
            description "A monetary value number"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::Money < Types::BaseScalar
              description "A monetary value " \
                          "number"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::Money < Types::BaseScalar
              description <<~MSG
                A monetary value number
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::Money < Types::BaseScalar
              description MONEY_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::Money < Types::BaseScalar
              description DESCRIPTION[:money]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Types::Money < Types::BaseScalar
                ^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when union" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Types::CommentSubject < Types::BaseUnion
            description "Objects which may be commented on"
          end
        RUBY
      end

      context "when description is multiline" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::CommentSubject < Types::BaseUnion
              description "Objects which may be commented " \
                          "on"
            end
          RUBY
        end
      end

      context "when description is heredoc" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::Money < Types::BaseScalar
              description <<~MSG
              Objects which may be commented on
              MSG
            end
          RUBY
        end
      end

      context "when description is a constant" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::CommentSubject < Types::BaseUnion
              description COMMENT_SUBJECT_DESCRIPTION
            end
          RUBY
        end
      end

      context "when description is a constant hash" do
        it "does not register an offense" do
          expect_no_offenses(<<~RUBY)
            class Types::CommentSubject < Types::BaseUnion
              description DESCRIPTION[:comment_subject]
            end
          RUBY
        end
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Types::CommentSubject < Types::BaseUnion
                ^^^^^^^^^^^^^^^^^^^^^ Missing type description
          end
        RUBY
      end
    end
  end

  context "when namespaced" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          module Types
            module Inputs
              class UserCreateInput < ::Types::Base::InputObject
                description I18n.t("graphql.inputs.user_create_input.desc")
              end
            end
          end
        RUBY
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          module Types
            module Inputs
              class UserCreateInput < ::Types::Base::InputObject
                    ^^^^^^^^^^^^^^^ Missing type description
              end
            end
          end
        RUBY
      end
    end
  end

  context "when with fields" do
    context "when description is filled" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class Types::UserType < Types::BaseObject
            graphql_name "UserType"

            description "Represents application user"

            field :first_name, String, null: true, description: "User's first name"
          end
        RUBY
      end
    end

    context "when description is not filled" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class Types::UserType < Types::BaseObject
                ^^^^^^^^^^^^^^^ Missing type description
            graphql_name "UserType"

            field :first_name, String, null: true, description: "User's first name"
          end
        RUBY
      end
    end
  end

  context "when the class is not a GraphQL type" do
    it "does not register an offense for an error class" do
      expect_no_offenses(<<~RUBY)
        class TrackingInfoNotAvailable < StandardError; end
      RUBY
    end

    it "does not register an offense for an error class nested in a mutation" do
      expect_no_offenses(<<~RUBY)
        class Mutations::ApplyPromotion < GraphQL::Schema::Resolver
          description "Applies a promotion"

          class OrderNotFound < Errors::PreconditionFailed; end
        end
      RUBY
    end

    it "does not register an offense for a query analyzer" do
      expect_no_offenses(<<~RUBY)
        class QueryDepthAnalyzer < GraphQL::Analysis::AST::Analyzer
        end
      RUBY
    end

    it "does not register an offense for a schema validator" do
      expect_no_offenses(<<~RUBY)
        class PositiveNumberValidator < GraphQL::Schema::Validator
        end
      RUBY
    end

    it "does not register an offense for a Rails generator" do
      expect_no_offenses(<<~RUBY)
        class MutationGenerator < Rails::Generators::NamedBase
        end
      RUBY
    end

    it "does not register an offense for a batch loader" do
      expect_no_offenses(<<~RUBY)
        class UserLoader < GraphQL::Batch::Loader
        end
      RUBY
    end

    it "does not register an offense for a custom connection" do
      expect_no_offenses(<<~RUBY)
        class UsersConnection < GraphQL::Pagination::Connection
        end
      RUBY
    end

    it "does not register an offense for a Sorbet struct" do
      expect_no_offenses(<<~RUBY)
        class BackingObject < T::Struct
          const :id, String
        end
      RUBY
    end

    it "does not register an offense for a Sorbet enum" do
      expect_no_offenses(<<~RUBY)
        class IneligibleReason < T::Enum
          enums do
            Unknown = new("UNKNOWN")
          end
        end
      RUBY
    end

    it "does not register an offense for a class with no superclass" do
      expect_no_offenses(<<~RUBY)
        class UserPresenter
          def call; end
        end
      RUBY
    end

    it "does not register an offense when the superclass is not a plain constant" do
      expect_no_offenses(<<~RUBY)
        class Point < Struct.new(:x, :y)
        end
      RUBY
    end

    it "does not register an offense for a class inheriting a non-GraphQL `Interface` base" do
      expect_no_offenses(<<~RUBY)
        class BillsPaginatedQuery < Pagination::PaginatedApi::Interface
        end
      RUBY
    end
  end

  context "when the type is an abstract base" do
    it "does not register an offense for a base object" do
      expect_no_offenses(<<~RUBY)
        class BaseObject < GraphQL::Schema::Object
          field :page_info, PageInfo, null: false
        end
      RUBY
    end

    it "does not register an offense for a base named exactly Base" do
      expect_no_offenses(<<~RUBY)
        class Base < GraphQL::Schema::Object
        end
      RUBY
    end

    it "does not register an offense for a base carrying a domain prefix" do
      expect_no_offenses(<<~RUBY)
        class BaseTimeOffMutation < Types::Base::Mutation
        end
      RUBY
    end

    it "does not register an offense for a base interface module" do
      expect_no_offenses(<<~RUBY)
        module BaseInterface
          include GraphQL::Schema::Interface
        end
      RUBY
    end

    it "registers an offense for a type whose name merely starts with the letters of Base" do
      expect_offense(<<~RUBY)
        class Basename < Types::Base::Object
              ^^^^^^^^ Missing type description
        end
      RUBY
    end
  end

  context "when the type is a root operation type" do
    it "does not register an offense for Query" do
      expect_no_offenses(<<~RUBY)
        class Query < Types::BaseObject
          field :users, [Types::UserType], null: false
        end
      RUBY
    end

    it "does not register an offense for Mutation" do
      expect_no_offenses(<<~RUBY)
        class Mutation < Types::BaseObject
        end
      RUBY
    end

    it "does not register an offense for a root type renamed via graphql_name" do
      expect_no_offenses(<<~RUBY)
        class EmptyQuery < Types::BaseObject
          graphql_name "Query"
        end
      RUBY
    end

    context "when IgnoreRootTypes is false" do
      let(:cop_config) { { "IgnoreRootTypes" => false } }

      it "registers an offense for Query" do
        expect_offense(<<~RUBY)
          class Query < Types::BaseObject
                ^^^^^ Missing type description
          end
        RUBY
      end

      it "registers an offense for a root type renamed via graphql_name" do
        expect_offense(<<~RUBY)
          class EmptyQuery < Types::BaseObject
                ^^^^^^^^^^ Missing type description
            graphql_name "Query"
          end
        RUBY
      end
    end
  end

  context "when AdditionalTypeBases is configured" do
    let(:cop_config) { { "AdditionalTypeBases" => %w[ApplicationType Describable] } }

    it "registers an offense for a class inheriting a configured base" do
      expect_offense(<<~RUBY)
        class Types::UserType < ApplicationType
              ^^^^^^^^^^^^^^^ Missing type description
        end
      RUBY
    end

    it "does not register an offense when that class has a description" do
      expect_no_offenses(<<~RUBY)
        class Types::UserType < ApplicationType
          description "Represents application user"
        end
      RUBY
    end

    it "registers an offense for a module including a configured base" do
      expect_offense(<<~RUBY)
        module Types::Node
               ^^^^^^^^^^^ Missing type description
          include Describable
        end
      RUBY
    end

    it "still ignores unrelated bases" do
      expect_no_offenses(<<~RUBY)
        class UserPresenter < ApplicationPresenter
        end
      RUBY
    end
  end

  context "when the module is not an interface" do
    it "does not register an offense for a plain module" do
      expect_no_offenses(<<~RUBY)
        module Helpers
          def self.call; end
        end
      RUBY
    end

    it "does not register an offense for a module including a concern" do
      expect_no_offenses(<<~RUBY)
        module Helpers
          include ActiveSupport::Concern
        end
      RUBY
    end

    it "does not register an offense for a module whose include has no argument" do
      expect_no_offenses(<<~RUBY)
        module Helpers
          include
        end
      RUBY
    end
  end

  context "when the interface module has other statements" do
    it "registers an offense when a plain concern is included alongside the interface" do
      expect_offense(<<~RUBY)
        module Types::NodeInterface
               ^^^^^^^^^^^^^^^^^^^^ Missing type description
          include Helpers
          include Types::BaseInterface
        end
      RUBY
    end

    it "does not register an offense when the description precedes the include" do
      expect_no_offenses(<<~RUBY)
        module Types::NodeInterface
          description "An object with an ID"
          include Types::BaseInterface
        end
      RUBY
    end

    it "registers an offense when `description` is called on an explicit receiver" do
      expect_offense(<<~RUBY)
        module Types::NodeInterface
               ^^^^^^^^^^^^^^^^^^^^ Missing type description
          include Types::BaseInterface
          config.description "not the type description"
        end
      RUBY
    end
  end
end
