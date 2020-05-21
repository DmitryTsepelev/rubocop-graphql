# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldDescription do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it "not registers an offense" do
    expect_no_offenses(<<~RUBY)
      class UserType < BaseType
        field :first_name, String, "First name", null: true
      end
    RUBY
  end

  it "registers an offense" do
    expect_offense(<<~RUBY)
      class UserType < BaseType
        field :first_name, String, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing field description
      end
    RUBY
  end
end
