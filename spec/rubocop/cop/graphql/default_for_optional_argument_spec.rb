# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::DefaultForOptionalArgument, :config do
  context "when a class-level optional argument has no default in resolve" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(name:); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when an optional argument has a default in resolve" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(name: nil); end
        end
      RUBY
    end
  end

  context "when an optional argument has a non-nil default in resolve" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :limit, Integer, required: false

          def resolve(limit: 10); end
        end
      RUBY
    end
  end

  context "when the argument is required" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: true

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when required: is not given at all" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when required: :nullable" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: :nullable

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when the optional argument declares a default_value" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false, default_value: "anonymous"

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when the optional argument declares default_value: nil" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false, default_value: nil

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when authorized? takes the optional argument without a default" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def authorized?(name:); end
                          ^^^^^ Optional argument `name` has no default value in `authorized?`, so omitting it raises ArgumentError.

          def resolve(name: nil); end
        end
      RUBY
    end
  end

  context "when both resolve and authorized? are missing defaults" do
    it "registers an offense for each" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def authorized?(name:); end
                          ^^^^^ Optional argument `name` has no default value in `authorized?`, so omitting it raises ArgumentError.

          def resolve(name:); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when several optional arguments are missing defaults" do
    it "registers an offense for each" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false
          argument :limit, Integer, required: false

          def resolve(name:, limit:); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
                             ^^^^^^ Optional argument `limit` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when only one of several arguments is missing a default" do
    it "registers an offense for that one" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false
          argument :limit, Integer, required: false

          def resolve(name: nil, limit:); end
                                 ^^^^^^ Optional argument `limit` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when the signature collects keywords with **rest" do
    it "still registers an offense for the explicit keyword" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(name:, **rest); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when the signature only collects keywords with **rest" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(**rest); end
        end
      RUBY
    end
  end

  context "when the signature takes a positional arguments hash" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(args); end
        end
      RUBY
    end
  end

  context "when there is no resolver method" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeInput < Types::BaseInputObject
          argument :name, String, required: false
        end
      RUBY
    end
  end

  context "when the class is empty" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
        end
      RUBY
    end
  end

  context "when the class has no arguments" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          def resolve(name:); end
        end
      RUBY
    end
  end

  context "when argument is called with no arguments" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument

          def resolve(name:); end
        end
      RUBY
    end
  end

  context "with an `as:` override" do
    it "registers an offense on the overridden keyword" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :post_id, ID, required: false, as: :article

          def resolve(article:); end
                      ^^^^^^^^ Optional argument `article` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end

    it "does not register an offense on the declared name" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :post_id, ID, required: false, as: :article

          def resolve(article: nil, post_id:); end
        end
      RUBY
    end
  end

  context "with a `loads:` argument" do
    it "registers an offense on the inferred singular keyword" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :user_id, ID, required: false, loads: Types::UserType

          def resolve(user:); end
                      ^^^^^ Optional argument `user` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end

    it "registers an offense on the inferred plural keyword" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :comment_ids, [ID], required: false, loads: Types::CommentType

          def resolve(comments:); end
                      ^^^^^^^^^ Optional argument `comments` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end

    it "prefers `as:` over the inferred keyword" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :user_id, ID, required: false, loads: Types::UserType, as: :author

          def resolve(author:); end
                      ^^^^^^^ Optional argument `author` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "when the argument is declared with a block" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false do
            description "The name"
          end

          def resolve(name:); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
        end
      RUBY
    end
  end

  context "with an argument inside a field block" do
    it "registers an offense against the field resolver method" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :posts, [PostType], null: false do
            argument :limit, Integer, required: false
          end

          def posts(limit:); end
                    ^^^^^^ Optional argument `limit` has no default value in `posts`, so omitting it raises ArgumentError.
        end
      RUBY
    end

    it "does not register an offense when the keyword has a default" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :posts, [PostType], null: false do
            argument :limit, Integer, required: false
          end

          def posts(limit: 10); end
        end
      RUBY
    end

    it "does not attribute the argument to resolve" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :posts, [PostType], null: false do
            argument :limit, Integer, required: false
          end

          def resolve(limit:); end
        end
      RUBY
    end

    it "honors resolver_method:" do
      expect_offense(<<~RUBY)
        class UserType < BaseObject
          field :posts, [PostType], null: false, resolver_method: :all_posts do
            argument :limit, Integer, required: false
          end

          def all_posts(limit:); end
                        ^^^^^^ Optional argument `limit` has no default value in `all_posts`, so omitting it raises ArgumentError.
        end
      RUBY
    end

    it "ignores fields resolved by a separate resolver class" do
      expect_no_offenses(<<~RUBY)
        class UserType < BaseObject
          field :posts, resolver: Resolvers::Posts do
            argument :limit, Integer, required: false
          end

          def posts(limit:); end
        end
      RUBY
    end
  end

  context "with two classes in the same file" do
    it "does not leak arguments from one class into the other" do
      expect_offense(<<~RUBY)
        class FirstResolver < Resolvers::Base
          argument :name, String, required: false

          def resolve(name:); end
                      ^^^^^ Optional argument `name` has no default value in `resolve`, so omitting it raises ArgumentError.
        end

        class SecondResolver < Resolvers::Base
          def resolve(name:); end
        end
      RUBY
    end
  end

  context "with a nested class" do
    it "does not attribute the outer arguments to the inner resolver" do
      expect_no_offenses(<<~RUBY)
        class OuterResolver < Resolvers::Base
          argument :name, String, required: false

          class InnerResolver < Resolvers::Base
            def resolve(name:); end
          end

          def resolve(name: nil); end
        end
      RUBY
    end
  end

  context "when the resolver method is defined inside a nested module" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :name, String, required: false

          module Helpers
            def resolve(name:); end
          end
        end
      RUBY
    end
  end
end
