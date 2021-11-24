# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldUniqueness do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when fields are not duplicated" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone, String, null: true do
            argument :something, String, required: false
          end
        end
      RUBY
    end
  end

  context "when a field is duplicated" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :name, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field names should only be defined once per type. Field `name` is duplicated.
          field :phone, String, null: true do
            argument :something, String, required: false
          end
        end
      RUBY
    end
  end

  context "when a block field is duplicated" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone, String, null: true
          field :phone, String, null: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field names should only be defined once per type. Field `phone` is duplicated.
            argument :something, String, required: false
          end
        end
      RUBY
    end
  end

  context "when a multi-line field is duplicated" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone,
                String,
                null: true
          field :phone,
          ^^^^^^^^^^^^^ Field names should only be defined once per type. Field `phone` is duplicated.
                String,
                null: true
        end
      RUBY
    end
  end
end
