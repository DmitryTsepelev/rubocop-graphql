# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ObjectDescription do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

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
end
