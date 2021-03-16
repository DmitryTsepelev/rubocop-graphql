# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::OrderedArguments do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when arguments are alphabetically sorted" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false
        end
      RUBY
    end
  end

  context "when each individual groups are alphabetically sorted" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true

          argument :email, String, required: false
          argument :name, String, required: false
        end
      RUBY
    end
  end

  context "when arguments are alphabetically sorted inside a field declaration" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :posts, PostType do
            argument :created_after, ISO8601DateTime, required: false
            argument :created_before, ISO8601DateTime, required: false
          end
        end
      RUBY
    end
  end

  context "when arguments are not alphabetically sorted" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
          argument :name, String, required: false
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false
          argument :uuid, ID, required: true
        end
      RUBY
    end
  end

  context "when arguments are not alphabetically sorted inside a field declaration" do
    it "not registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :posts, PostType do
            argument :created_before, ISO8601DateTime, required: false
            argument :created_after, ISO8601DateTime, required: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `created_after` should appear before `created_before`.
          end
        end
      RUBY
    end
  end

  context "when an unordered argument declaration takes several lines" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid,
                   ID,
                   required: true
          argument :email, String, required: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
          argument :name, String, required: false
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false
          argument :uuid,
                   ID,
                   required: true
        end
      RUBY
    end
  end
end
