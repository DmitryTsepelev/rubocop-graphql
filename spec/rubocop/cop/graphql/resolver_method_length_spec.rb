# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ResolverMethodLength, :config do

  let(:config) do
    RuboCop::Config.new(
      "GraphQL/ResolverMethodLength" => {
        "Max" => 2,
        "ExcludedMethods" => []
      }
    )
  end

  it "not registers an offense" do
    expect_no_offenses(<<~RUBY)
      class UserType < BaseType
        field :first_name, String, null: true

        def first_name
          line_1
          line_2
        end
      end
    RUBY
  end

  context "when resolver method is longer than Max lines" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true

          def first_name
          ^^^^^^^^^^^^^^ ResolverMethod has too many lines. [3/2]
            line_1
            line_2
            line_3
          end
        end
      RUBY
    end

    context "when multiple fields are defined" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true
            field :last_name, String, null: true

            def first_name
            ^^^^^^^^^^^^^^ ResolverMethod has too many lines. [3/2]
              line_1
              line_2
              line_3
            end
          end
        RUBY
      end
    end
  end

  context "when method is not a GraphQL resolver method" do
    it "not registers an offense when resolver method is longer than Max lines" do
      expect_no_offenses(<<~RUBY)
        class SomeClass
          def first_name
            line_1
            line_2
            line_3
          end
        end
      RUBY
    end
  end
end
