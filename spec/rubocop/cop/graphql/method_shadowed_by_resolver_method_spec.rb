# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::MethodShadowedByResolverMethod, :config do
  it "does not register an offense when neither resolver: nor resolver_method: is set" do
    expect_no_offenses(<<~RUBY)
      class UserType < BaseType
        field :name, String, null: true

        def name
          object.name
        end
      end
    RUBY
  end

  context "with resolver:" do
    it "does not register an offense when no method shadows it" do
      expect_no_offenses(<<~RUBY)
        class PostType < BaseType
          field :author, resolver: AuthorResolver
        end
      RUBY
    end

    it "registers an offense for a field-named method" do
      expect_offense(<<~RUBY)
        class PostType < BaseType
          field :author, resolver: AuthorResolver

          def author
              ^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
            object.author
          end
        end
      RUBY
    end

    it "registers an offense only for the shadowed method when valid fields are around" do
      expect_offense(<<~RUBY)
        class PostType < BaseType
          field :name, String, null: false
          field :author, resolver: AuthorResolver

          def name
            object.name
          end

          def author
              ^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
            object.author
          end
        end
      RUBY
    end

    context "and resolver_method: is also set (it has no effect once resolver: is set)" do
      it "registers an offense for the field-named method" do
        expect_offense(<<~RUBY)
          class PostType < BaseType
            field :author, resolver: AuthorResolver, resolver_method: :fetch_author

            def author
                ^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end
          end
        RUBY
      end

      it "also registers an offense for the resolver_method-named method alone" do
        expect_offense(<<~RUBY)
          class PostType < BaseType
            field :author, resolver: AuthorResolver, resolver_method: :fetch_author

            def fetch_author
                ^^^^^^^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end
          end
        RUBY
      end

      it "registers two offenses when both methods are defined" do
        expect_offense(<<~RUBY)
          class PostType < BaseType
            field :author, resolver: AuthorResolver, resolver_method: :fetch_author

            def author
                ^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end

            def fetch_author
                ^^^^^^^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end
          end
        RUBY
      end
    end

    context "and method: is also set (it has no effect once resolver: is set)" do
      it "registers an offense for the method:-named method" do
        expect_offense(<<~RUBY)
          class PostType < BaseType
            field :author, resolver: AuthorResolver, method: :ghostwriter

            def ghostwriter
                ^^^^^^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end
          end
        RUBY
      end

      it "registers two offenses when both the field-named and method:-named methods are defined" do
        expect_offense(<<~RUBY)
          class PostType < BaseType
            field :author, resolver: AuthorResolver, method: :ghostwriter

            def author
                ^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end

            def ghostwriter
                ^^^^^^^^^^^ Remove this method, it is never called: `resolver: AuthorResolver` resolves this field instead.
              object.author
            end
          end
        RUBY
      end
    end
  end

  context "with resolver_method: alone (no resolver:)" do
    it "does not register an offense when only the resolver_method-named method is defined" do
      expect_no_offenses(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, resolver_method: :fetch_author

          def fetch_author
            object.author
          end
        end
      RUBY
    end

    it "registers an offense for a leftover field-named method, not the live resolver_method one" do
      expect_offense(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, resolver_method: :fetch_author

          def author
              ^^^^^^ Remove this method, it is never called: `resolver_method: :fetch_author` is called instead.
            object.author
          end

          def fetch_author
            object.author
          end
        end
      RUBY
    end

    it "does not register an offense when resolver_method: matches the field name" do
      expect_no_offenses(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, resolver_method: :author

          def author
            object.author
          end
        end
      RUBY
    end
  end
end
