# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldHashKey, :config do
  it "does not register an offense" do
    expect_no_offenses(<<~RUBY)
      class UserType < BaseType
        field :phone, String, null: true, hash_key: :home_phone
      end
    RUBY
  end

  context "when class has two fields" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :name, String, null: true
          field :phone, String, null: true, hash_key: :home_phone
        end
      RUBY
    end
  end

  context "when resolver method only retrieves the value by one key" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use hash_key: :home_phone

          def phone
            object[:home_phone]
          end
        end
      RUBY

      expect_correction(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true, hash_key: :home_phone
        end
      RUBY
    end

    context "when hash key is a string" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :phone, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use hash_key: "home_phone"

            def phone
              object["home_phone"]
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :phone, String, null: true, hash_key: "home_phone"
          end
        RUBY
      end
    end

    context "when hash key is an integer" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :phone, String, null: true

            def phone
              object[0]
            end
          end
        RUBY
      end
    end

    context "when there are valid fields around" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :name, String, null: false
            field :phone, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Use hash_key: :home_phone
            field :address, String, null: true

            def phone
              object[:home_phone]
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :name, String, null: false
            field :phone, String, null: true, hash_key: :home_phone
            field :address, String, null: true
          end
        RUBY
      end
    end

    context "when suggested hash_key name would conflict with Ruby or GraphQL-Ruby keywords" do
      it "does not register an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :context, String, null: true, resolver_method: :user_context

            def user_context
              object[:context]
            end
          end
        RUBY

        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :next, String, null: true, resolver_method: :user_next

            def user_next
              object['next']
            end
          end
        RUBY
      end
    end
  end

  context "when resolver method is more complex" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :phone, String, null: true

          def phone
            object[:contact][:home_phone]
          end
        end
      RUBY
    end
  end
end
