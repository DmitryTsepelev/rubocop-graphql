# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldHashKey do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

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
