# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnnecessaryArgumentCamelize, :config do
  context "when proper argument camelize defined" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do
            argument :foo_bar, String, required: true, camelize: true
          end
        end
      RUBY
    end

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do
            argument :foo_bar, String, required: true, camelize: false
          end
        end
      RUBY
    end
  end

  context "when unnecessary argument camelize defined" do
    it "registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true do
            argument :foo, String, required: true, camelize: false
          end
        end
      RUBY
    end
  end
end
