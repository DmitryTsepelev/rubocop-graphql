# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::LegacyDsl, :config do


  context "when legacy DSL is defined" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        User = GraphQL::Object.define do
               ^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using legacy based type-based definitions. Use class-based definitions instead.
               field :foo, type.String
        end
      RUBY
    end
  end

  context "when class-based type is defined" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true
        end
      RUBY
    end
  end
end
