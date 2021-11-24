# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::OrderedFields do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when fields are alphabetically sorted" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :birthdate, Int, null: true
          field :name, String, null: true
          field :phone, String, null: true do
            argument :something, String, required: false
          end
        end
      RUBY
    end
  end

  context "when duplicate fields are alphabetically sorted" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :birthdate, Int, null: true
          field :name, String, null: true
          field :name, String, null: true
          field :phone, String, null: true do
            argument :something, String, required: false
          end
        end
      RUBY
    end
  end

  context "when each individual groups are alphabetically sorted" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :birthdate, Int, null: true
          field :name, Staring, null: true

          field :email, String, null: true
          field :phone, String, null: true
        end
      RUBY
    end
  end

  context "when fields are not alphabetically sorted" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true
          field :name, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone, String, null: true
        end
      RUBY
    end
  end

  context "when duplicate fields are not alphabetically sorted" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone, String, null: true
          field :name, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :name, String, null: true
          field :phone, String, null: true
        end
      RUBY
    end
  end

  context "when block fields are not alphabetically sorted" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true
          field :name, String, null: true do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
            argument :something, String, required: false
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true do
            argument :something, String, required: false
          end
          field :phone, String, null: true
        end
      RUBY
    end
  end

  context "when a unordered field declaration take several lines" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :phone,
                String,
                null: true
          field :name, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone,
                String,
                null: true
        end
      RUBY
    end
  end
end
