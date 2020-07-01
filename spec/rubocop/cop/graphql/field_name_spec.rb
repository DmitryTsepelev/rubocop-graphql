# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldName do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when field name is in snake case" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true
        end
      RUBY
    end
  end

  context "when field name is in camel case" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :firstName, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use snake_case for field names
        end
      RUBY
    end
  end
end
