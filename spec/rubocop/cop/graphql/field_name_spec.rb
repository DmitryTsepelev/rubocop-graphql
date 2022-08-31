# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldName, :config do
  context "when field name is in snake case" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true
        end
      RUBY
    end
  end

  context "when field is called on an extension" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class MyExtension < GraphQL::Schema::FieldExtension
          def apply
            field.argument(:width, Integer, required: false)
          end
        end
      RUBY
    end
  end

  context "when field has no name" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field field: MyField
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

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true
        end
      RUBY
    end
  end
end
