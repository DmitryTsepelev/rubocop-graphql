# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldUniqueness, :config do
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

  context "when duplicated field name belongs to a nested class" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          class UserPhone < BaseType
            field :phone, String
            field :ext, String, null: true
          end

          field :name, String, null: true
          field :phone, UserPhone, null: true
        end
      RUBY
    end
  end

  context "when same fields defined in classes with the same name but in different namespaces" do
    it "does not register an offence" do
      expect_no_offenses(<<~RUBY)
        class RootMutationClassTest
          class UnitTest
            class MyType < TestType
              field :name, String, null: true
            end
          end

          class IntegrationTest
            class MyType < TestType
              field :name, String, null: true
            end
          end
        end
      RUBY
    end
  end

  context "when fields are duplicated in both root and nested classes" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class ParentType < BaseType
          class ChildType < BaseType
            field :name, String, null: true
            field :name, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field names should only be defined once per type. Field `name` is duplicated.

          end

          field :name, String
          field :child, ChildType
          field :child, ChildType
          ^^^^^^^^^^^^^^^^^^^^^^^ Field names should only be defined once per type. Field `child` is duplicated.
        end
      RUBY
    end
  end

  context "when a field is defined twice with different camelize values" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String
          field :first_name, String, camelize: false
        end
      RUBY
    end
  end

  context "when a field is with duplicated with camelize: true" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :last_name, String
          field :last_name, String, camelize: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field names should only be defined once per type. Field `last_name` is duplicated.
        end
      RUBY
    end
  end
end
