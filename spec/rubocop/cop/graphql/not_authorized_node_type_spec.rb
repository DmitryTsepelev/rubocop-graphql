# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::NotAuthorizedNodeType, :config do
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
    end
  end
end
