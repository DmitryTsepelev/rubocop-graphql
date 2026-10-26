# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryFieldAlias, :config do
  describe ":alias" do
    context "when proper field alias defined" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, alias: :proper_alias
          end
        RUBY
      end
    end

    context "when unnecessary field alias defined" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, alias: :first_name
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary :alias configured
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

  describe ":method" do
    context "when proper field method defined" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, method: :proper_alias
          end
        RUBY
      end
    end

    context "when unnecessary field method defined" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, method: :first_name
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary :method configured
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true
          end
        RUBY
      end
    end

    context "when the unnecessary method is laid out over several lines" do
      it "removes the whole line when it is in the middle" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  null: false,
                  method: :question,
                  description: "The question."
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String,
                  null: false,
                  description: "The question."
          end
        RUBY
      end

      it "keeps a comment on the previous line when it is in the middle" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  null: false, # keep me
                  method: :question,
                  description: "The question."
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String,
                  null: false, # keep me
                  description: "The question."
          end
        RUBY
      end

      it "removes the whole line when it is the first keyword" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  method: :question,
                  null: false
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String,
                  null: false
          end
        RUBY
      end

      it "removes the whole line when it is last" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  null: false,
                  method: :question
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String,
                  null: false
          end
        RUBY
      end

      it "keeps a comment trailing the previous keyword when it is last" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  null: false, # keep me, please
                  method: :question
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String,
                  null: false # keep me, please
          end
        RUBY
      end

      it "keeps a comment trailing the previous argument when it is the only keyword" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String, # the type
                  method: :question
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String # the type
          end
        RUBY
      end

      it "does not move a closing parenthesis into the comment of the previous keyword" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field(:question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  null: false, # keep me
                  method: :question)
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field(:question,
                  String,
                  null: false)
          end
        RUBY
      end

      it "removes the whole line when it is the only keyword" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question,
            ^^^^^^^^^^^^^^^^ Unnecessary :method configured
                  String,
                  method: :question
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question,
                  String
          end
        RUBY
      end

      it "removes the first keyword together with the separator after it" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :question, String, method: :question, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary :method configured
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :question, String, null: false
          end
        RUBY
      end
    end
  end

  describe ":resolver_method" do
    context "when proper field resolver_method defined" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, resolver_method: :proper_alias
          end
        RUBY
      end
    end

    context "when unnecessary field resolver_method defined" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, resolver_method: :first_name
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary :resolver_method configured
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

  describe ":hash_key" do
    context "when proper field hash_key defined" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, hash_key: :proper_alias
          end
        RUBY
      end
    end

    context "when unnecessary field hash_key defined" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, hash_key: :first_name
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary :hash_key configured
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
end
