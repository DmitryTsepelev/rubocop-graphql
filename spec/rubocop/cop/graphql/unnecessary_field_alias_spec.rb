# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryFieldAlias, :config do
  context "when proper field alias defined" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true, alias: :proper_alias
        end
      RUBY
    end
  end

  context "when unnecessary field alias defined" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true, alias: :first_name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary field alias
        end
      RUBY
    end
  end
end
