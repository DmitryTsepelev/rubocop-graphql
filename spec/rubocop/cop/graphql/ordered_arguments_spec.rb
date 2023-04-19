# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::OrderedArguments, :config do
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

  context "when duplicate arguments are alphabetically sorted" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
          argument :name, String, required: false
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

  context "when duplicate arguments are not alphabetically sorted" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
          argument :name, String, required: false
          argument :email, String, required: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `name`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false
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

  context "when an unordered argument declaration uses heredoc" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: false, description: <<~DESC
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
            heredoc description
          DESC
          argument :name, String, required: false
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false, description: <<~DESC
            heredoc description
          DESC
          argument :name, String, required: false
          argument :uuid, ID, required: true
        end
      RUBY
    end
  end

  context "when an unordered argument declaration contains a block" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: false do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
            description 'the user email'
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false do
            description 'the user email'
          end
          argument :uuid, ID, required: true
        end
      RUBY
    end
  end

  context "when multiple unordered argument declarations contain blocks" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :uuid, ID, required: true do
            description 'the profile UUID'
          end
          argument :email, String, required: false do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `email` should appear before `uuid`.
            description 'the user email'
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UpdateProfile < BaseMutation
          argument :email, String, required: false do
            description 'the user email'
          end
          argument :uuid, ID, required: true do
            description 'the profile UUID'
          end
        end
      RUBY
    end
  end

  context "when Order config is specified" do
    let(:config) do
      RuboCop::Config.new(
        "GraphQL/OrderedArguments" => {
          "Order" => %w[id /^id_.*$/ /^.*_id$/ everything-else /^(created|updated)_at$/]
        }
      )
    end

    context "when there are no blocks" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :alpha, String, null: true
            argument :id, ID, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `id` should appear before `alpha`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, null: false
            argument :alpha, String, null: true
          end
        RUBY
      end

      it "registers complex offenses 1" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, null: false
            argument :created_at, Date, null: false
            argument :zelda, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `zelda` should appear before `created_at`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, null: false
            argument :zelda, String, null: true
            argument :created_at, Date, null: false
          end
        RUBY
      end

      it "registers complex offenses 2" do
        expect_offense(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :updated_at, Date, null: false
            argument :created_at, Date, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `created_at` should appear before `updated_at`.
            argument :deleted_at, Date, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `deleted_at` should appear before `created_at`.
            argument :zelda, String, null: false
            argument :link, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `link` should appear before `zelda`.
            argument :id_kind, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `id_kind` should appear before `link`.
            argument :org_id, String, null: true
            argument :id, ID, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Arguments should be sorted in an alphabetical order within their section. Field `id` should appear before `org_id`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UpdateProfile < BaseMutation
            argument :id, ID, null: false
            argument :id_kind, String, null: false
            argument :org_id, String, null: true
            argument :deleted_at, Date, null: false
            argument :link, String, null: false
            argument :zelda, String, null: false
            argument :created_at, Date, null: false
            argument :updated_at, Date, null: false
          end
        RUBY
      end
    end
  end

end
