# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::GraphqlName, :config do
  let(:config) do
    RuboCop::Config.new(
      "GraphQL/GraphqlName" => {
        "EnforcedStyle" => enforced_style,
        "SupportedStyles" => %w[required only_override]
      }
    )
  end

  context "when EnforcedStyle is required" do
    let(:enforced_style) { "required" }

    context "when graphql_name is configured" do
      specify do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            graphql_name 'User'
          end
        RUBY
      end
    end

    context "when graphql_name is not configured" do
      specify do
        expect_offense(<<~RUBY)
          class UserType < BaseType
          ^^^^^^^^^^^^^^^^^^^^^^^^^ graphql_name should be configured.
          end
        RUBY
      end
    end
  end

  context "when EnforcedStyle is only_override" do
    let(:enforced_style) { "only_override" }

    context "when type" do
      context "when graphql_name is not configured" do
        specify do
          expect_no_offenses(<<~RUBY)
            class UserType < BaseType
            end
          RUBY
        end
      end

      context "when graphql_name is configured" do
        context "when graphql_name matches type name" do
          specify do
            expect_offense(<<~RUBY)
              class UserType < BaseType
              ^^^^^^^^^^^^^^^^^^^^^^^^^ graphql_name should be specified only for overrides.
                graphql_name 'User'
              end
            RUBY
          end
        end

        context "when graphql_name not matches type name" do
          specify do
            expect_no_offenses(<<~RUBY)
              class UserType < BaseType
                graphql_name 'Viewer'
              end
            RUBY
          end
        end

        context "when namespaced" do
          context "when graphql_name matches type name" do
            specify do
              expect_offense(<<~RUBY)
                class Admin::UserType < BaseType
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ graphql_name should be specified only for overrides.
                  graphql_name 'User'
                end
              RUBY
            end
          end

          context "when graphql_name matches not type name" do
            specify do
              expect_no_offenses(<<~RUBY)
                class Admin::UserType < BaseType
                  graphql_name 'Viewer'
                end
              RUBY
            end
          end
        end
      end
    end

    context "when mutation" do
      context "when graphql_name is not configured" do
        specify do
          expect_no_offenses(<<~RUBY)
            class CreateUserMutation < BaseMutation
            end
          RUBY
        end
      end

      context "when graphql_name is configured" do
        context "when graphql_name matches mutation name" do
          specify do
            expect_offense(<<~RUBY)
              class CreateUserMutation < BaseMutation
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ graphql_name should be specified only for overrides.
                graphql_name 'CreateUserMutation'
              end
            RUBY
          end
        end

        context "when graphql_name not matches mutation name" do
          specify do
            expect_no_offenses(<<~RUBY)
              class User::CreateMutation < BaseMutation
                graphql_name 'CreateUser'
              end
            RUBY
          end
        end

        context "when namespaced" do
          context "when graphql_name matches mutation name" do
            specify do
              expect_offense(<<~RUBY)
                class User::CreateMutation < BaseMutation
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ graphql_name should be specified only for overrides.
                  graphql_name 'CreateMutation'
                end
              RUBY
            end
          end

          context "when graphql_name not matches mutation name" do
            specify do
              expect_no_offenses(<<~RUBY)
                class User::CreateMutation < BaseMutation
                  graphql_name 'CreateUser'
                end
              RUBY
            end
          end
        end
      end
    end
  end
end
