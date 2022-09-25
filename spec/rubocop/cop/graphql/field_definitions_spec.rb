# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::FieldDefinitions, :config do
  let(:config) do
    RuboCop::Config.new(
      "GraphQL/FieldDefinitions" => {
        "EnforcedStyle" => enforced_style,
        "SupportedStyles" => %w[group_definitions define_resolver_after_definition]
      }
    )
  end

  context "when EnforcedStyle is group_definitions" do
    let(:enforced_style) { "group_definitions" }

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true
          field :last_name, String, null: true
        end
      RUBY
    end

    context "when class is empty" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
          end
        RUBY
      end
    end

    context "when resolver methods are after field definitions" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true
            field :last_name, String, null: true

            def first_name
              object.contact_data.first_name
            end

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end

      context "when resolver methods have Sorbet signatures" do
        it "not registers an offense" do
          expect_no_offenses(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true
              field :last_name, String, null: true

              sig { returns(String) }
              def first_name
                object.contact_data.first_name
              end

              sig { returns(String) }
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY
        end
      end

      context "when resolver methods have multiline Sorbet signatures" do
        it "not registers an offense" do
          expect_no_offenses(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true
              field :last_name, String, null: true

              sig do
                T.nilable(returns(String))
              end
              def first_name
                object.contact_data.first_name
              end

              sig do
                T.nilable(returns(String))
              end
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY
        end
      end
    end

    context "when field has no kwargs" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, ID
          end
        RUBY
      end
    end

    context "when field has block" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, ID, null: false
            field :image_url, String, null: false do
              argument :width, Integer, required: false
              argument :height, Integer, required: false
            end
            field :last_name, String, null: true
          end
        RUBY
      end
    end

    context "when field definitions are not grouped together" do
      it "registers an offense" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Group all field definitions together.

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            field :last_name, String, null: true


            def first_name
              object.contact_data.first_name
            end

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end

      context "when resolver methods have Sorbet signatures" do
        it "registers an offense" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              sig { returns(String) }
              def first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Group all field definitions together.

              sig { returns(String) }
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              field :last_name, String, null: true


              sig { returns(String) }
              def first_name
                object.contact_data.first_name
              end

              sig { returns(String) }
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY
        end
      end

      context "when resolver methods have multiline Sorbet signatures" do
        it "registers an offense" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              sig do
                T.nilable(returns(String))
              end
              def first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Group all field definitions together.

              sig do
                T.nilable(returns(String))
              end
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              field :last_name, String, null: true


              sig do
                T.nilable(returns(String))
              end
              def first_name
                object.contact_data.first_name
              end

              sig do
                T.nilable(returns(String))
              end
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY
        end
      end
    end
  end

  context "when EnforcedStyle is define_resolver_after_definition" do
    let(:enforced_style) { "define_resolver_after_definition" }

    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseType
          field :first_name, String, null: true

          def first_name
            object.contact_data.first_name
          end

          field :last_name, String, null: true

          def last_name
            object.contact_data.last_name
          end
        end
      RUBY
    end

    context "when resolver methods have Sorbet signatures" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            sig { returns(String) }
            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true

            sig { returns(String) }
            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when resolver methods have multiline Sorbet signatures" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            sig do
              T.nilable(returns(String))
            end
            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true

            sig do
              T.nilable(returns(String))
            end
            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when field has a heredoc description" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, description: <<~DESC
              First Name.
            DESC

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true, description: <<~DESC
              Last Name.
            DESC

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when class has single field" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true
          end
        RUBY
      end
    end

    context "when there is no method definition" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true
          end
        RUBY
      end
    end

    context "when :resolver is configured" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, resolver: FirstNameResolver
            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when :method is configured" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, method: :contact_first_name
            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when :hash_key is configured" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, hash_key: :name1
            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end
    end

    context "when field has block" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, ID, null: false

            def first_name
              object.name
            end

            field :image_url, String, null: false do
              argument :width, Integer, required: false
              argument :height, Integer, required: false
            end

            def image_url
              object.url
            end
          end
        RUBY
      end
    end

    context "when resolver method is not defined right after field definition" do
      it "registers offenses" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
            field :last_name, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

            def first_name
              object.contact_data.first_name
            end

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end

          end
        RUBY
      end

      it "registers offenses when field has a heredoc description" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, description: <<~DESC
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
              First name.
            DESC
            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end

            def first_name
              object.contact_data.first_name
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :first_name, String, null: true, description: <<~DESC
              First name.
            DESC

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end

      it "registers offenses when type classes are nested within a module" do
        expect_offense(<<~RUBY)
          module Types
            class UserType < BaseType
              field :first_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

              def first_name
                object.contact_data.first_name
              end

              def last_name
                object.contact_data.last_name
              end
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          module Types
            class UserType < BaseType
              field :first_name, String, null: true

              def first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true

              def last_name
                object.contact_data.last_name
              end

            end
          end
        RUBY
      end

      context "when custom :resolver_method is configured for field" do
        it "registers offenses" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true, resolver_method: :custom_first_name
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

              def custom_first_name
                object.contact_data.first_name
              end

              def last_name
                object.contact_data.last_name
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true, resolver_method: :custom_first_name

              def custom_first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true

              def last_name
                object.contact_data.last_name
              end

            end
          RUBY
        end
      end

      context "when field has block" do
        it "registers an offense" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, ID, null: false
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

              field :image_url, String, null: false do
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
                argument :width, Integer, required: false
                argument :height, Integer, required: false
              end

              def first_name
                object.name
              end

              def image_url
                object.url
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, ID, null: false

              def first_name
                object.name
              end


              field :image_url, String, null: false do
                argument :width, Integer, required: false
                argument :height, Integer, required: false
              end

              def image_url
                object.url
              end

            end
          RUBY
        end
      end

      context "when resolver methods have Sorbet signatures" do
        it "registers offenses" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

              sig { returns(String) }
              def first_name
                object.contact_data.first_name
              end

              sig { returns(String) }
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              sig { returns(String) }
              def first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true

              sig { returns(String) }
              def last_name
                object.contact_data.last_name
              end

            end
          RUBY
        end
      end

      context "when resolver methods have multiline Sorbet signatures" do
        it "registers offenses" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
              field :last_name, String, null: true
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.

              sig do
                T.nilable(returns(String))
              end
              def first_name
                object.contact_data.first_name
              end

              sig do
                T.nilable(returns(String))
              end
              def last_name
                object.contact_data.last_name
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :first_name, String, null: true

              sig do
                T.nilable(returns(String))
              end
              def first_name
                object.contact_data.first_name
              end

              field :last_name, String, null: true

              sig do
                T.nilable(returns(String))
              end
              def last_name
                object.contact_data.last_name
              end

            end
          RUBY
        end
      end

      context "when multiple fields share a resolver method" do
        context "when one field has the resolver method's name" do
          it "registers offense to and moves resolver after the field with the resolver's name" do
            expect_offense(<<~RUBY)
              class UserType < BaseType
                field :first_name, String, null: true
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after field definition.
                field :last_name, String, null: true, resolver_method: :first_name

                def first_name
                  object.contact_data.first_name
                end
              end
            RUBY

            expect_correction(<<~RUBY)
              class UserType < BaseType
                field :first_name, String, null: true

                def first_name
                  object.contact_data.first_name
                end

                field :last_name, String, null: true, resolver_method: :first_name
              end
            RUBY
          end
        end

        context "when no fields have the resolver method's name" do
          it "registers offense to and moves resolver after the last field sharing the resolver" do
            expect_offense(<<~RUBY)
              class UserType < BaseType
                field :first_name, String, null: true, resolver_method: :name

                def name
                  object.contact_data.name
                end

                field :last_name, String, null: true, resolver_method: :name
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after last field definition sharing resolver method.
              end
            RUBY

            expect_correction(<<~RUBY)
              class UserType < BaseType
                field :first_name, String, null: true, resolver_method: :name

                field :last_name, String, null: true, resolver_method: :name

                def name
                  object.contact_data.name
                end

              end
            RUBY
          end
        end
      end
    end

    context "when there are multiple field definitions" do
      it "not register an offense when resolver is defined after the last field definitions" do
        expect_no_offenses(<<~RUBY)
          class UserType < BaseType
            field :first_name, Name, null: true
            field :first_name, String, null: true

            def first_name
              object.contact_data.first_name
            end

            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end

      it "registers an offense when resolver is defined before the last field definition" do
        expect_offense(<<~RUBY)
          class UserType < BaseType
            field :first_name, Name, null: true

            def first_name
              object.contact_data.first_name
            end

            field :first_name, String, null: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after last field definition sharing resolver method.

            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY

        expect_correction(<<~RUBY)
          class UserType < BaseType
            field :first_name, Name, null: true

            field :first_name, String, null: true

            def first_name
              object.contact_data.first_name
            end


            field :last_name, String, null: true

            def last_name
              object.contact_data.last_name
            end
          end
        RUBY
      end

      context "when the field nodes are same but the field definitions are not" do
        it "not register an offense when resolver is defined after the last field definition" do
          expect_no_offenses(<<~RUBY)
            class UserType < BaseType
              field :image_url, String, null: false do
                argument :width, Integer, required: false
              end
              field :image_url, String, null: false do
                argument :width, Integer, required: false
                argument :height, Integer, required: false
              end

              def image_url
                object.image_url
              end

              field :first_name, String, null: false
            end
          RUBY
        end

        it "register an offense when when resolver method is before the last field definition" do
          expect_offense(<<~RUBY)
            class UserType < BaseType
              field :image_url, String, null: false do
                argument :width, Integer, required: false
              end

              def image_url
                object.image_url
              end

              field :image_url, String, null: false do
              ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Define resolver method after last field definition sharing resolver method.
                argument :width, Integer, required: false
                argument :height, Integer, required: false
              end
            end
          RUBY

          expect_correction(<<~RUBY)
            class UserType < BaseType
              field :image_url, String, null: false do
                argument :width, Integer, required: false
              end

              field :image_url, String, null: false do
                argument :width, Integer, required: false
                argument :height, Integer, required: false
              end

              def image_url
                object.image_url
              end

            end
          RUBY
        end
      end
    end
  end
end
