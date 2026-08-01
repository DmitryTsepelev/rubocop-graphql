# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UselessMethodOption, :config do
  it "does not register an offense when resolver: is set alone" do
    expect_no_offenses(<<~RUBY)
      class PostType < BaseType
        field :author, resolver: AuthorResolver
      end
    RUBY
  end

  it "does not register an offense when resolver_method: is set without resolver:" do
    expect_no_offenses(<<~RUBY)
      class PostType < BaseType
        field :author, String, null: true, resolver_method: :fetch_author
      end
    RUBY
  end

  it "does not register an offense when method: is set without resolver:" do
    expect_no_offenses(<<~RUBY)
      class PostType < BaseType
        field :author, String, null: true, method: :ghostwriter
      end
    RUBY
  end

  it "registers an offense for resolver_method: alongside resolver:, even with no matching def" do
    expect_offense(<<~RUBY)
      class PostType < BaseType
        field :author, resolver: AuthorResolver, resolver_method: :fetch_author
                                                 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `resolver_method:`, it has no effect: `resolver: AuthorResolver` always takes precedence.
      end
    RUBY
  end

  it "registers an offense for method: alongside resolver:, even with no matching method" do
    expect_offense(<<~RUBY)
      class PostType < BaseType
        field :author, resolver: AuthorResolver, method: :ghostwriter
                                                 ^^^^^^^^^^^^^^^^^^^^ Remove `method:`, it has no effect: `resolver: AuthorResolver` always takes precedence.
      end
    RUBY
  end

  it "registers an offense for a namespaced resolver class" do
    expect_offense(<<~RUBY)
      class PostType < BaseType
        field :author, resolver: Resolvers::AuthorResolver, resolver_method: :fetch_author
                                                            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Remove `resolver_method:`, it has no effect: `resolver: Resolvers::AuthorResolver` always takes precedence.
      end
    RUBY
  end

  context "when method: is shadowed by a same-named def, with no resolver: involved" do
    it "registers an offense for method: when a def matching the plain field name exists" do
      expect_offense(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, method: :ghostwriter
                                             ^^^^^^^^^^^^^^^^^^^^ Remove `method:`, it has no effect: `def author` on the type always takes precedence.

          def author
            object.author
          end
        end
      RUBY
    end

    it "does not register an offense when the def matches method:'s own name instead" do
      expect_no_offenses(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, method: :ghostwriter

          def ghostwriter
            object.author
          end
        end
      RUBY
    end

    it "does not register an offense for resolver_method: with a coexisting def" do
      expect_no_offenses(<<~RUBY)
        class PostType < BaseType
          field :author, String, null: true, resolver_method: :fetch_author

          def author
            object.author
          end
        end
      RUBY
    end
  end
end
