# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldDescription, :config do
  context "when description is passed as argument" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, "First name", null: true
        end
      RUBY
    end

    context "when passed as heredoc" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :foo_bar,
              [String],
              <<~TXT,
                description text
                more text
              TXT
              null: false
          end
        RUBY
      end
    end
  end

  context "when description is passed as kwarg" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, description: "First name", null: true
        end
      RUBY
    end

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :foo_bar,
            [String],
            description: <<~TXT,
              description text
              more text
            TXT
            null: false
        end
      RUBY
    end
  end

  context "when description is passed inside block" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do
            description "First name"
          end
        end
      RUBY
    end

    context "when block also contains something else" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true do
              description "First name"

              argument :capitalized, String, required: false
            end
          end
        RUBY
      end
    end
  end

  context "when description is set inside block with argument" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do |field|
            field.description = "First name"
          end
        end
      RUBY
    end

    context "when block also contains something else" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true do |field|
              field.description = "First name"

              field.argument :capitalized, String, required: false
            end
          end
        RUBY
      end
    end
  end

  context "when description is passed inside block with argument" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do |field|
            field.description "First name"
          end
        end
      RUBY
    end

    context "when block also contains something else" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true do |field|
              field.description "First name"

              field.argument :capitalized, String, required: false
            end
          end
        RUBY
      end
    end
  end

  it "registers an offense" do
    expect_offense(<<~RUBY)
      class UserType < BaseType
        field :first_name, String, null: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing field description
      end
    RUBY
  end

  context "when field has block" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing field description
            argument :short, Boolean, required: false
          end
        end
      RUBY
    end
  end
end
