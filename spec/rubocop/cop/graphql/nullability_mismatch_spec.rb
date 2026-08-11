# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::NullabilityMismatch, :config do
  context "when a non-null field has a nilable resolver" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the field is nullable" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: true

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the signature is not nilable" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          sig { override.returns(String) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the signature returns T.untyped" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          sig { override.returns(T.untyped) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when there is no signature at all" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the signature has no returns" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          sig { void }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with T.any including NilClass" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.any(String, NilClass)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with T.any not including NilClass" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          sig { override.returns(T.any(String, Symbol)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with a nilable element inside a non-nilable collection" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :names, [String, null: true], null: false

          sig { override.returns(T::Array[T.nilable(String)]) }
          def names
            object.names
          end
        end
      RUBY
    end
  end

  context "with a nilable collection" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :names, [String], null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `names` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.nilable(T::Array[String])) }
          def names
            object.names
          end
        end
      RUBY
    end
  end

  context "with a params signature" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { params(upcase: T::Boolean).returns(T.nilable(String)) }
          def name(upcase: false)
            object.name
          end
        end
      RUBY
    end
  end

  context "with a fully qualified ::T" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(::T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the field is defined with a block" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false do
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.
            description "The name"
          end

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with resolver_method:" do
    it "registers an offense against the remapped method" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false, resolver_method: :full_name
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.nilable(String)) }
          def full_name
            object.full_name
          end
        end
      RUBY
    end

    it "does not attribute a same-named method to the field" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false, resolver_method: :full_name

          sig { override.returns(String) }
          def full_name
            object.full_name
          end

          sig { returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the field is handed off to a resolver class" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, resolver: Resolvers::Name, null: false

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with an interface module" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        module UserInterface
          include Types::BaseInterface

          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with a nested type" do
    it "does not attribute the inner method to the outer field" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          class AddressType < BaseObject
            sig { override.returns(T.nilable(String)) }
            def name
              object.name
            end
          end

          sig { override.returns(String) }
          def name
            object.name
          end
        end
      RUBY
    end

    it "does not attribute the inner field to the outer method" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          class AddressType < BaseObject
            field :name, String, null: false
          end

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "with two types in the same file" do
    it "checks each independently" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Field `name` is `null: false` but its resolver signature returns a nilable type, so a nil resolves to an invalid null error.

          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end

        class AddressType < BaseObject
          field :name, String, null: false

          sig { override.returns(String) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the type has no fields" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          sig { override.returns(T.nilable(String)) }
          def name
            object.name
          end
        end
      RUBY
    end
  end

  context "when the nilable method does not back a field" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :name, String, null: false

          sig { override.returns(String) }
          def name
            nickname || object.name
          end

          sig { returns(T.nilable(String)) }
          def nickname
            object.nickname
          end
        end
      RUBY
    end
  end
end
