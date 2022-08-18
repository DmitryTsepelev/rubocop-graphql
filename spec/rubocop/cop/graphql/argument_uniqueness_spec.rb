# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ArgumentUniqueness, :config do

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

    context "when field name is a variable" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field_name = "field_name"

            field field_name, PostType do
              argument :created_after, ISO8601DateTime, required: false
              argument :created_after, ISO8601DateTime, required: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `created_after` is duplicated in field with name from `field_name` variable.
              argument :created_before, ISO8601DateTime, required: false
            end
          end
        RUBY
      end
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

  context "when same arguments defined in classes with the same name but different namespaces" do
    it "does not register an offence" do
      expect_no_offenses(<<~RUBY)
        class RootMutationClassTest
          class UnitTest
            class Input < TestType
              argument :test_argument, String, required: false
            end
          end

          class IntegrationTest
            class Input < TestType
              argument :test_argument, String, required: false
            end
          end
        end
      RUBY
    end
  end

  context "when duplicated field names belong to different nested classes" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class RootMutationClass < BaseMutation
          argument :test_argument, String, required: false

          field :test_field, TestType do
            argument :test_argument, String, required: false
          end

          class NestedInputType < TestType
            argument :test_argument, String, required: false

            field :test_field, TestType do
              argument :test_argument, String, required: false
            end
          end
        end
      RUBY
    end

    context "when duplicated field names belong to a nested class" do
      it "registers an offence" do
        expect_offense(<<~RUBY)
          class RootMutationClass < BaseMutation
            argument :unique_argument, NestedInputType, required: false

            class NestedInputType < TestType
              argument :test_argument, String, required: false
              argument :test_argument, String, required: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `test_argument` is duplicated.

              field :test_field, TestType do
                argument :field_arg, String, required: false
                argument :field_arg, String, required: false
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Argument names should only be defined once per block. Argument `field_arg` is duplicated in field `test_field`.

              end
            end
          end
        RUBY
      end
    end
  end

  # context "wer" do
  #   it "qweqwe" do
  #     expect_no_offenses(<<~RUBY)
  #       class Types::BaseObject < GraphQL::Schema::Object
  #         include Graphql::Authenticatable

  #         field_class Types::BaseField

  #         connection_type_class Types::BaseConnection

  #         def self.connection_field(name, type, **kwargs)
  #           # field(name, type, **kwargs) do
  #           field test_field, TestType do
  #             argument :filters, [String], required: false
  #             argument :name, String, required: false
  #             argument :order, [String], required: false
  #             argument :scopes, [String], required: false

  #             yield self if block_given?
  #           end
  #         end
  #       end
  #     RUBY
  #   end
  # end
end
