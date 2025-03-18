# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::OrderedFields, :config do
  let(:config) do
    RuboCop::Config.new(
      "GraphQL/OrderedFields" => {
        "Groups" => true
      }
    )
  end

  context "when there is a block" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :birthdate, Int, null: true do
            description 'foo'
          end
          field :abc, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `abc` should appear before `birthdate`.
        end
      RUBY
    end
  end

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

  context "when grouped fields are not alphabetically sorted" do
    it "does not register an offense" do
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

  context "when group config is false" do
    let(:config) do
      RuboCop::Config.new(
        "GraphQL/OrderedFields" => {
          "Groups" => false
        }
      )
    end

    context "when there are blocks" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :phone, String, null: true do
              argument :something, String, required: false
            end
            field :name, String, null: true do
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :name, String, null: true do
            end
            field :phone, String, null: true do
              argument :something, String, required: false
            end
          end
        RUBY
      end
    end

    context "when there are no blocks" do
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
  end

  context "when Order config is specified" do
    let(:config) do
      RuboCop::Config.new(
        "GraphQL/OrderedFields" => {
          "Order" => %w[id /^id_.*$/ /^.*_id$/ everything-else /^(created|updated)_at$/]
        }
      )
    end

    context "when there are no blocks" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :alpha, String, null: true
            field :id, ID, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `id` should appear before `alpha`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :id, ID, null: false
            field :alpha, String, null: true
          end
        RUBY
      end

      it "registers complex offenses 1" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :id, ID, null: false
            field :created_at, Date, null: false
            field :zelda, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `zelda` should appear before `created_at`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :id, ID, null: false
            field :zelda, String, null: true
            field :created_at, Date, null: false
          end
        RUBY
      end

      it "registers complex offenses 2" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :updated_at, Date, null: false
            field :created_at, Date, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `created_at` should appear before `updated_at`.
            field :deleted_at, Date, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `deleted_at` should appear before `created_at`.
            field :zelda, String, null: false
            field :link, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `link` should appear before `zelda`.
            field :id_kind, String, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `id_kind` should appear before `link`.
            field :org_id, String, null: true
            field :id, ID, null: false
            ^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `id` should appear before `org_id`.
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :id, ID, null: false
            field :id_kind, String, null: false
            field :org_id, String, null: true
            field :deleted_at, Date, null: false
            field :link, String, null: false
            field :zelda, String, null: false
            field :created_at, Date, null: false
            field :updated_at, Date, null: false
          end
        RUBY
      end
    end
  end

  context "when fields are not alphabetically sorted inside an interface" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        module UserType
          include GraphQL::Schema::Interface

          field :phone, String, null: true
          field :name, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
        end
      RUBY

      expect_correction(<<~RUBY)
        module UserType
          include GraphQL::Schema::Interface

          field :name, String, null: true
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

  context "when a unordered field declaration uses heredocs" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true
          field :name, String, null: true, description: <<~HEREDOC
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `name` should appear before `phone`.
            heredoc_example
          HEREDOC
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true, description: <<~HEREDOC
            heredoc_example
          HEREDOC
          field :phone, String, null: true
        end
      RUBY
    end
  end

  context "with multiple offenses" do
    it "orders all fields alphabetically" do
      expect_offense(<<~RUBY)
        class SomeType < Types::BaseObject
          field :id, Integer
          field :some_field, Integer
          field :field_too, Integer
          ^^^^^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `field_too` should appear before `some_field`.
          field :field, Integer
          ^^^^^^^^^^^^^^^^^^^^^ Fields should be sorted in an alphabetical order within their section. Field `field` should appear before `field_too`.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeType < Types::BaseObject
          field :field, Integer
          field :field_too, Integer
          field :id, Integer
          field :some_field, Integer
        end
      RUBY
    end
  end
end
