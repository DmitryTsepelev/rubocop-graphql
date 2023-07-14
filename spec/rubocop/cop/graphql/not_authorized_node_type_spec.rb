# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::NotAuthorizedNodeType, :config do
  let(:config) do
    RuboCop::Config.new(
      "GraphQL/NotAuthorizedNodeType" => {
        "SafeBaseClasses" => ["BaseUserType", "Types::OtherBaseUserType"]
      }
    )
  end

  context "when type not implements Node interface" do
    specify do
      expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :uuid, ID, null: false
        end
      RUBY
    end
  end

  context "when type implements Node interface" do
    context "when type has .authorized? check" do
      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType < BaseType
            implements GraphQL::Types::Relay::Node

            field :uuid, ID, null: false

            def self.authorized?(object, context)
              super && object.owner == context[:viewer]
            end
          end
        RUBY
      end
    end

    context "when type has .authorized? check using class << self" do
      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType < BaseType
            implements GraphQL::Types::Relay::Node

            field :uuid, ID, null: false

            class << self
              def authorized?(object, context)
                super && object.owner == context[:viewer]
              end
            end
          end
        RUBY
      end
    end

    context "when type has no .authorized? check" do
      specify do
        expect_offense(<<~RUBY, "graphql/types/user_type.rb")
          class UserType < BaseType
          ^^^^^^^^^^^^^^^^^^^^^^^^^ .authorized? should be defined for types implementing Node interface.
            implements GraphQL::Types::Relay::Node

            field :uuid, ID, null: false
          end
        RUBY
      end

      context "when type in SafeBaseClasses" do
        specify do
          expect_offense(<<~RUBY, "graphql/types/user_type.rb")
            class BaseUserType < BaseType
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ .authorized? should be defined for types implementing Node interface.
              implements GraphQL::Types::Relay::Node

              field :uuid, ID, null: false
            end
          RUBY
        end
      end

      context "when type inherits from one of SafeBaseClasses" do
        specify do
          expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
            class UserType < BaseUserType
              implements GraphQL::Types::Relay::Node

              field :uuid, ID, null: false
            end
          RUBY
        end

        specify do
          expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
            module Types
              class UserType < BaseUserType
                implements GraphQL::Types::Relay::Node

                field :uuid, ID, null: false
              end
            end
          RUBY
        end

        specify do
          expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
            module Types
              class UserType < ::BaseUserType
                implements GraphQL::Types::Relay::Node

                field :uuid, ID, null: false
              end
            end
          RUBY
        end

        specify do
          expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
            module Types
              class UserType < OtherBaseUserType
                implements GraphQL::Types::Relay::Node

                field :uuid, ID, null: false
              end
            end
          RUBY
        end

        specify do
          expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
            module Types
              class UserType < Types::OtherBaseUserType
                implements GraphQL::Types::Relay::Node

                field :uuid, ID, null: false
              end
            end
          RUBY
        end
      end
    end

    context "when type has a pundit_role" do
      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType
            implements GraphQL::Types::Relay::Node

            pundit_role :staff

            field :uuid, ID, null: false
          end
        RUBY
      end

      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType
            implements GraphQL::Types::Relay::Node

            pundit_role nil

            field :uuid, ID, null: false
          end
        RUBY
      end
    end

    context "when type has a can_can_action" do
      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType
            implements GraphQL::Types::Relay::Node

            can_can_action :read

            field :uuid, ID, null: false
          end
        RUBY
      end

      specify do
        expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
          class UserType
            implements GraphQL::Types::Relay::Node

            can_can_action nil

            field :uuid, ID, null: false
          end
        RUBY
      end
    end
  end
end
