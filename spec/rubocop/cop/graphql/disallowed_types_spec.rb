# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::DisallowedTypes, :config do
  let(:cop_config) do
    { "Types" => { "Float" => "Use Types::Decimal, which serializes as a string." } }
  end

  context "with a disallowed field type" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        field :amount, Float, null: false
                       ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end
  end

  context "with a disallowed argument type" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        argument :amount, Float, required: true
                          ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end
  end

  context "with an allowed type" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        field :amount, Types::Decimal, null: false
        argument :amount, Types::Decimal, required: true
      RUBY
    end
  end

  context "with a type whose name merely contains the disallowed name" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        field :amount, FloatingRate, null: false
        field :other, MyFloat, null: false
      RUBY
    end
  end

  context "when nothing is configured" do
    let(:cop_config) { { "Types" => {} } }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        field :amount, Float, null: false
      RUBY
    end
  end

  context "when Types is missing entirely" do
    let(:cop_config) { {} }

    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        field :amount, Float, null: false
      RUBY
    end
  end

  context "with a namespaced form of the configured name" do
    it "registers an offense for a single namespace" do
      expect_offense(<<~RUBY)
        field :amount, Types::Float, null: false
                       ^^^^^^^^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end

    it "registers an offense for a nested namespace" do
      expect_offense(<<~RUBY)
        field :amount, GraphQL::Types::Float, null: false
                       ^^^^^^^^^^^^^^^^^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end

    it "registers an offense for a fully qualified constant" do
      expect_offense(<<~RUBY)
        field :amount, ::GraphQL::Types::Float, null: false
                       ^^^^^^^^^^^^^^^^^^^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end
  end

  context "when the configured name is itself namespaced" do
    let(:cop_config) do
      { "Types" => { "Types::LegacyDate" => "Use GraphQL::Types::ISO8601Date." } }
    end

    it "registers an offense for the configured form" do
      expect_offense(<<~RUBY)
        field :starts_on, Types::LegacyDate, null: false
                          ^^^^^^^^^^^^^^^^^ `Types::LegacyDate` is not allowed as a field or argument type. Use GraphQL::Types::ISO8601Date.
      RUBY
    end

    it "registers an offense for a longer namespace ending in it" do
      expect_offense(<<~RUBY)
        field :starts_on, MySchema::Types::LegacyDate, null: false
                          ^^^^^^^^^^^^^^^^^^^^^^^^^^^ `Types::LegacyDate` is not allowed as a field or argument type. Use GraphQL::Types::ISO8601Date.
      RUBY
    end

    it "does not register an offense for the bare final segment" do
      expect_no_offenses(<<~RUBY)
        field :starts_on, LegacyDate, null: false
      RUBY
    end
  end

  context "with a list type" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        field :amounts, [Float], null: false
                         ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end

    it "registers an offense when the list carries options" do
      expect_offense(<<~RUBY)
        field :amounts, [Float, null: true], null: false
                         ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end

    it "registers an offense for a nested list" do
      expect_offense(<<~RUBY)
        field :amounts, [[Float]], null: false
                          ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end
  end

  context "with the type: keyword" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        field :amount, type: Float, null: false
                             ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end

    it "registers an offense for a list" do
      expect_offense(<<~RUBY)
        argument :amounts, type: [Float], required: true
                                  ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal, which serializes as a string.
      RUBY
    end
  end

  context "with no reason configured" do
    let(:cop_config) { { "Types" => { "Float" => "" } } }

    it "registers an offense with the default message" do
      expect_offense(<<~RUBY)
        field :amount, Float, null: false
                       ^^^^^ `Float` is not allowed as a field or argument type.
      RUBY
    end
  end

  context "with a nil reason configured" do
    let(:cop_config) { { "Types" => { "Float" => nil } } }

    it "registers an offense with the default message" do
      expect_offense(<<~RUBY)
        field :amount, Float, null: false
                       ^^^^^ `Float` is not allowed as a field or argument type.
      RUBY
    end
  end

  context "with several disallowed types" do
    let(:cop_config) do
      { "Types" => { "Float" => "Use Types::Decimal.", "Types::LegacyDate" => "Use ISO8601Date." } }
    end

    it "registers an offense for each" do
      expect_offense(<<~RUBY)
        field :amount, Float, null: false
                       ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal.
        field :starts_on, Types::LegacyDate, null: false
                          ^^^^^^^^^^^^^^^^^ `Types::LegacyDate` is not allowed as a field or argument type. Use ISO8601Date.
      RUBY
    end
  end

  context "inside a type class" do
    let(:cop_config) { { "Types" => { "Float" => "Use Types::Decimal." } } }

    it "registers an offense" do
      expect_offense(<<~RUBY)
        class PaymentType < BaseObject
          field :amount, Float, null: false do
                         ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal.
            argument :precision, Float, required: false
                                 ^^^^^ `Float` is not allowed as a field or argument type. Use Types::Decimal.
          end
        end
      RUBY
    end
  end

  context "when the type is not a constant" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        field :amount, resolver_type, null: false
        field :amount, null: false
        field :amount
      RUBY
    end
  end

  context "when a local variable shadows the disallowed name" do
    it "does not register an offense on unrelated calls" do
      expect_no_offenses(<<~RUBY)
        Float(value)
        something.field(:amount, Float)
      RUBY
    end
  end
end
