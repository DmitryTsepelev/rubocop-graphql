# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ExtractType do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      "GraphQL/ExtractType" => {
        "MaxFields" => 2
      }
    )
  end

  it "not registers an offense" do
    expect_no_offenses(<<~RUBY)
      class UserType < BaseType
        field :registered_at, String, null: false
      end
    RUBY
  end

  context "when count fields with common prefix equal Max fields" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :registered_at, String, null: false

          field :contact_first_name, String, null: false
          field :contact_last_name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_first_name, contact_last_name to a new type and adding the `contact` field instead
        end
      RUBY
    end

    context "when field with body" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :contact_first_name, String, null: false
            field :contact_last_name, String, null: false do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_first_name, contact_last_name to a new type and adding the `contact` field instead
              argument :start_with, String, required: false
            end
          end
        RUBY
      end
    end

    context "when one field name in camel-case notation" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :contact_first_name, String, null: false
            field :contactLastName, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_first_name, contactLastName to a new type and adding the `contact` field instead
          end
        RUBY
      end
    end

    context "when all field names in camel-case notation" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :contactFirstName, String, null: false
            field :contactLastName, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contactFirstName, contactLastName to a new type and adding the `contact` field instead
          end
        RUBY
      end
    end
  end

  context "when count fields with common prefix more than Max fields" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :registered_at, String, null: false

          field :contact_first_name, String, null: false
          field :contact_last_name, String, null: false
          field :contact_patronymic, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_first_name, contact_last_name, contact_patronymic to a new type and adding the `contact` field instead
        end
      RUBY
    end
  end

  context "when a few groups with exceeded quantity of fields with common prefix detected" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :registered_at, String, null: false
          field :contact_first_name, String, null: false
          field :contact_last_name, String, null: false
          field :contact_patronymic, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_first_name, contact_last_name, contact_patronymic to a new type and adding the `contact` field instead

          field :bio_weight, String, null: false
          field :bio_height, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving bio_weight, bio_height to a new type and adding the `bio` field instead
        end
      RUBY
    end
  end
end
