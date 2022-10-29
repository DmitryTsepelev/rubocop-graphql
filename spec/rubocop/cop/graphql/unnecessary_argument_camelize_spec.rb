# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryArgumentCamelize, :config do
  context "when proper field camelize defined" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class User < BaseType
          field :avatar_url, String do
            argument :size, Integer, "Size of avatar", required: true
          end
        end
      RUBY
    end

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class User < BaseType
          field :avatar_url, String do
            argument :size_example, Integer, "Size of avatar", required: true, camelize: true
          end
        end
      RUBY
    end

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class User < BaseType
          argument :size_example, Integer, "Size of avatar", required: true, camelize: true
        end
      RUBY
    end
  end

  context "when unnecessary argument camelize defined" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          argument :first, String, null: true, camelize: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary argument camelize
        end
      RUBY
    end

    context "when defined within block" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :avatar_url, String do
              argument :first, String, null: true, camelize: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Unnecessary argument camelize
            end
          end
        RUBY
      end
    end
  end
end
