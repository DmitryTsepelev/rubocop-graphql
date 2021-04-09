# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ArgumentDescription do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  context "when description is passed as argument" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class BanUser < BaseMutation
          argument :uuid, ID, "UUID of the user to ban", required: true
        end
      RUBY
    end
  end

  context "when description is passed as kwarg" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class BanUser < BaseMutation
          argument :uuid, ID, required: true, description: "UUID of the user to ban"
        end
      RUBY
    end
  end

  context "when description is passed inside block" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class BanUser < BaseMutation
          argument :uuid, ID, required: true do
            description "UUID of the user to ban"
          end
        end
      RUBY
    end
  end

  it "registers an offense" do
    expect_offense(<<~RUBY)
      class BanUser < BaseMutation
        argument :uuid, ID, required: true
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing argument description
      end
    RUBY
  end

  context "when argument is inside field block" do
    context "when description is passed as argument" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, "Size of avatar", required: true
            end
          end
        RUBY
      end
    end

    context "when description is passed as kwarg" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, description: "Size of avatar", required: true
            end
          end
        RUBY
      end
    end

    context "when description is passed inside block" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, required: true do
                description "Size of avatar"
              end
            end
          end
        RUBY
      end
    end

    context "when description is passed inside block as a single line heredoc" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, required: true do
                description <<~EOT
                  Size of avatar
                EOT
              end
            end
          end
        RUBY
      end
    end

    context "when description is passed inside block as a multiline heredoc" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, required: true do
                description <<~EOT
                  Size
                  of
                  avatar
                EOT
              end
            end
          end
        RUBY
      end
    end

    context "when description is passed inside block as a processed multiline heredoc" do
      it "not registers an offense" do
        expect_no_offenses(<<~RUBY)
          class User < BaseType
            field :avatar_url, String do
              argument :size, Integer, required: true do
                description <<-EOT.strip
                  Size
                  of
                  avatar
                EOT
              end
            end
          end
        RUBY
      end
    end

    it "registers an offense" do
      expect_offense(<<~RUBY)
        class User < BaseType
          field :avatar_url, String do
            argument :size, Integer, required: true
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Missing argument description
          end
        end
      RUBY
    end
  end
end
