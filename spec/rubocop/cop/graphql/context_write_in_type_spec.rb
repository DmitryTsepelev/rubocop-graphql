# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ContextWriteInType, :config do
  context "when writing to context with bracket assignment" do
    it "registers an offense" do
      expect_offense(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            context[:current_user] = object.user
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid writing to `context` in GraphQL types. Mutating shared state can lead to unexpected behavior.
            object.name
          end
        end
      RUBY
    end
  end

  context "when writing to context with merge!" do
    it "registers an offense" do
      expect_offense(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            context.merge!(current_user: object.user)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid writing to `context` in GraphQL types. Mutating shared state can lead to unexpected behavior.
            object.name
          end
        end
      RUBY
    end
  end

  context "when writing to context with store" do
    it "registers an offense" do
      expect_offense(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            context.store(:current_user, object.user)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid writing to `context` in GraphQL types. Mutating shared state can lead to unexpected behavior.
            object.name
          end
        end
      RUBY
    end
  end

  context "when reading from context" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            viewer = context[:current_user]
            object.name
          end
        end
      RUBY
    end
  end

  context "when calling other methods on context" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            context.fetch(:current_user)
          end
        end
      RUBY
    end
  end

  context "when writing to a different object with bracket assignment" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY, "graphql/types/user_type.rb")
        class UserType < BaseType
          field :name, String, null: false

          def name
            hash = {}
            hash[:key] = "value"
            object.name
          end
        end
      RUBY
    end
  end
end
