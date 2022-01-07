# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::UnusedArgument do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when all args are used" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class SomeResolver < Resolvers::Base
          argument :arg1, String, required: true
          argument :arg2, String, required: false

          def resolve(arg1:, arg2: "hey"); end
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
end
