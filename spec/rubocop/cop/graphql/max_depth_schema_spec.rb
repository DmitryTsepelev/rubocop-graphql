# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::MaxDepthSchema, :config do
  context "when schema has max_depth" do
    specify do
      expect_no_offenses(<<~RUBY, "./graphql/app_schema.rb")
        class AppSchema < BaseSchema
          max_depth 42
        end
      RUBY
    end
  end

  context "when schema has no max_depth" do
    specify do
      expect_offense(<<~RUBY, "./graphql/app_schema.rb")
        class AppSchema < BaseSchema
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ max_depth should be configured for schema.
        end
      RUBY
    end
  end
end
