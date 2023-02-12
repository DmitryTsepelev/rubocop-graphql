# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::MaxComplexitySchema, :config do
  context "when schema has max_complexity" do
    specify do
      expect_no_offenses(<<~RUBY, "./graphql/app_schema.rb")
        class AppSchema < BaseSchema
          max_complexity 42
        end
      RUBY
    end
  end

  context "when schema has no max_complexity" do
    specify do
      expect_offense(<<~RUBY, "./graphql/app_schema.rb")
        class AppSchema < BaseSchema
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ max_complexity should be configured for schema.
        end
      RUBY
    end
  end
end
