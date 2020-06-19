# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ExtractType do
  subject(:cop) { described_class.new(config) }

  let(:config) do
    RuboCop::Config.new(
      "GraphQL/ExtractType" => {
        "MaxFields" => 2,
        "Prefixes" => %w[is avg min max]
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

  context "when count of fields with common prefix equals to Max fields" do
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

    context "when field has body" do
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

    context "when one field name is in camel-case notation" do
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

    context "when all field names are in camel-case notation" do
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

    context "when common prefix is listed in Prefixes" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :is_admin, String, null: false
            field :is_director, String, null: false
          end
        RUBY
      end
    end

    context "when common prefix is composite" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :contact_info_first_name, String, null: false
            field :contact_info_last_name, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_info_first_name, contact_info_last_name to a new type and adding the `contact_info` field instead
          end
        RUBY
      end
    end
  end

  context "when count of fields with common prefix is more than Max fields" do
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

    context "when common prefixes are composite" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :registered_at, String, null: false

            field :contact_bio_weight, String, null: false

            field :contact_info_first_name, String, null: false

            field :contact_info_last_name, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_info_first_name, contact_info_last_name to a new type and adding the `contact_info` field instead

            field :contact_email, String, null: false

            field :contact_bio_height, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_bio_weight, contact_bio_height to a new type and adding the `contact_bio` field instead

            field :contact_mobile_phone, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving contact_email, contact_mobile_phone to a new type and adding the `contact` field instead
          end
        RUBY
      end
    end
  end
end
