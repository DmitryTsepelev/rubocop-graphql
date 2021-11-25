# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ArgumentUniqueness do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when arguments are not duplicated" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false
        end
      RUBY
    end
  end

  context "when arguments are duplicated between field and root" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false

          field :photos, PhotoType do
            argument :name, String, required: false
          end
        end
      RUBY
    end
  end

  context "when arguments are duplicated across different field definitions" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          field :photos, PhotoType do
            argument :created_after, ISO8601DateTime, required: false
            argument :created_before, ISO8601DateTime, required: false
          end

          field :posts, PostType do
            argument :created_after, ISO8601DateTime, required: false
            argument :created_before, ISO8601DateTime, required: false
          end
        end
      RUBY
    end
  end

  context "when an argument is duplicated" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :email, String, required: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `email` is duplicated.
          argument :name, String, required: false
        end
      RUBY
    end
  end

  context "when an argument is duplicated within a field definition" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :posts, PostType do
            argument :created_after, ISO8601DateTime, required: false
            argument :created_after, ISO8601DateTime, required: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `created_after` is duplicated in field `posts`.
            argument :created_before, ISO8601DateTime, required: false
          end
        end
      RUBY
    end
  end

  context "when a multi-line argument is duplicated" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :email,
          ^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `email` is duplicated.
                   String,
                   required: false
          argument :name, String, required: false
        end
      RUBY
    end
  end
end
