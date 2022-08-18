# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnusedArgument, :config do


  context "when all args are used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          class Input < GraphQL::Schema::InputObject
            argument :arg4, String, required: true
          end

          argument :arg1, String, required: true
          argument :arg2, String, required: false
          argument :arg3, Input, required: true

          def resolve(arg1:, arg2: "hey", arg3:); end
        end
      RUBY
    end
  end

  context "when first arg and splats arg are used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(arg1:, **rest); end
        end
      RUBY
    end
  end

  context "when args with loads are used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :post_id, String, loads: Types::PostType
          argument :comment_ids, String, loads: Types::CommentType
          argument :user_id, String, loads: Types::UserType, as: :owner
          argument :notes_ids, String, loads: Types::NoteType, as: :remarks
          argument :data, String, required: false, as: :metadata

          def resolve(post:, comments:, owner:, remarks:, metadata:); end
        end
      RUBY
    end
  end

  context "when field with arguments is used" do
    it "does not register an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :foo, String
          field :my_field, String, null: false do
            argument :bar, String
          end

          def resolve(foo:); end
        end
      RUBY
    end
  end

  context "when hash arg is used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(args); end
        end
      RUBY
    end
  end

  context "when splats arg is used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(**args); end
        end
      RUBY
    end
  end

  context "when not all args are used" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(arg1:); end
          ^^^^^^^^^^^^^^^^^^^^^^^ Argument `arg2:` should be listed in the resolve signature.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(arg1:, arg2:); end
        end
      RUBY
    end
  end

  context "when not all args are used, but some args declared twice" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true
          argument :arg2, String, required: true

          def resolve(arg1:); end
          ^^^^^^^^^^^^^^^^^^^^^^^ Argument `arg2:` should be listed in the resolve signature.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true
          argument :arg2, String, required: true

          def resolve(arg1:, arg2:); end
        end
      RUBY
    end
  end

  context "when args are not used at all" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true
          argument :user_id, String, loads: Types::UserType
          argument :card_ids, String, loads: Types::CardType
          argument :post_id, String, loads: Types::PostType, as: :article
          argument :comment_ids, String, loads: Types::CommentType, as: :notes

          def resolve; end
          ^^^^^^^^^^^^^^^^ Arguments `arg1:, arg2:, user:, cards:, article:, notes:` should be listed in the resolve signature.
        end
      RUBY

      expect_correction(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true
          argument :user_id, String, loads: Types::UserType
          argument :card_ids, String, loads: Types::CardType
          argument :post_id, String, loads: Types::PostType, as: :article
          argument :comment_ids, String, loads: Types::CommentType, as: :notes

          def resolve(arg1:, arg2:, user:, cards:, article:, notes:); end
        end
      RUBY
    end
  end

  context "when args is forwarding arguments" do
    let(:ruby_version) { 2.7 } # forward arguments was introduced in Ruby 2.7

    it "does not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: true

          def resolve(...); end
        end
      RUBY
    end
  end

  context "when resolve method belongs to a different class" do
    it "does not register an offence" do
      expect_no_offenses(<<~RUBY)
        class MyMutation < GraphApi::Mutation
          class MyHelper
            def resolve
            end
          end

          argument :arg1, String, required: true

          self.resolve = -> {}
        end
      RUBY
    end
  end
end
