# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryFieldCamelize, :config do
  context "when proper field camelize defined" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true, camelize: true
        end
      RUBY
    end

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true, camelize: false
        end
      RUBY
    end
  end

  context "when unnecessary field camelize defined" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :first, String, null: true, camelize: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary field camelize
        end
      RUBY
    end
  end
end
