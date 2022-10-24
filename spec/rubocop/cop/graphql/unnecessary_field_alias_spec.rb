# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryFieldAlias, :config do
  it "registers an offense" do
    expect_offense(<<~RUBY)
      class UserType < BaseType
        field :first_name, String, null: true, alias: :first_name
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^Unnecssary field alias
      end
    RUBY
  end
end
