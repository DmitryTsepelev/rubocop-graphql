# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ArgumentName, :config do


  context "when field name is in snake case" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class BanUser < BaseMutation
          argument :user_id, ID, required: true
        end
      RUBY
    end
  end

  context "when field name is in camel case" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class BanUser < BaseMutation
          argument :userId, ID, required: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use snake_case for argument names
        end
      RUBY
    end
  end
end
