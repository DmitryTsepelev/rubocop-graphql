# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::PrimaryKeyGroup, :config do
  context "given a PK in its own group" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :id, ID, required: true

          argument :name, String, required: false
          argument :email, String, required: false
        end
      RUBY
    end
    
    context "given only one PK as argument" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UpdateProfile < BaseMutation
            graphql_name "UpdateProfile"
      
            class Input < Inputs::BaseInput
              graphql_name "UpdateProfileInput"
    
              argument :id, Int, "User ID", required: true
            end
      
            argument :input, Input, required: true
          end
        RUBY
      end
      
      context "given a field declaration" do
        it "not registers an offense" do
          expect_no_offenses(<<~RUBY)
            class UpdateProfile < BaseMutation
              argument :profile, String, required: false
              field :user, PostType do
                argument :id, ID, required: true
              end
            end
          RUBY
        end
      end
    end
  end

  context "given a PK not on their own group" do
    context "given a PK at the top of the arguments list" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, required: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Primary keys should be in their own individual groups.
            argument :name, String, required: false
            argument :email, String, required: false
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, required: true

            argument :name, String, required: false
            argument :email, String, required: false
          end
        RUBY
      end
    end

    context "given a PK randomly added in the arguments list" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :name, String, required: false
            argument :id, ID, required: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Primary keys should be in their own individual groups.
            argument :email, String, required: false
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, required: true

            argument :name, String, required: false
            argument :email, String, required: false
          end
        RUBY
      end
    end

    context "given a field declaration" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :profile, String, required: false
            field :user, PostType do
              graphql_name "UpdateProfileInput"

              argument :id, ID, required: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Primary keys should be in their own individual groups.
              argument :name, String, required: false
              argument :email, String, required: false
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :profile, String, required: false
            field :user, PostType do
              graphql_name "UpdateProfileInput"

              argument :id, ID, required: true

              argument :name, String, required: false
              argument :email, String, required: false
            end
          end
        RUBY
      end
    end

    context "given a PK randomly added in the arguments list" do
      it "registers an offense"  do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :profile, String, required: false
            field :user, PostType do
              argument :name, String, required: false
              argument :id, ID, required: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Primary keys should be in their own individual groups.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :profile, String, required: false
            field :user, PostType do
              argument :id, ID, required: true

              argument :name, String, required: false
            end
          end
        RUBY
      end
    end
  end
end
