# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::ExtractInputType, :config do

  let(:config) do
    RuboCop::Config.new(
      "GraphQL/ExtractInputType" => {
        "MaxArguments" => 2
      }
    )
  end

  it "not registers an offense" do
    expect_no_offenses(<<~RUBY)
      class UpdateUser < BaseMutation
        argument :uuid, ID, required: true
        argument :user_attributes, UserAttributesInputType
      end
    RUBY
  end

  context "when count of arguments equals to Max arguments" do
    it "registers an offense" do
      expect_offense(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :first_name, String, required: true
          argument :last_name, String, required: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving arguments to a new input type
        end
      RUBY
    end
  end

  context "when count of fields is more than Max fields" do
    it "registers an offense for each line over Max fields" do
      expect_offense(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :first_name, String, required: true
          argument :last_name, String, required: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving arguments to a new input type
          argument :email, String, required: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving arguments to a new input type
        end
      RUBY
    end
  end

  context "when arguments are inside field block" do
    it "not registers an offense" do
      expect_no_offenses(<<~RUBY)
        class User < BaseType
          field :avatar_url, String do
            argument :width, Integer, required: true
            argument :height, Integer, required: true
            argument :format, String, required: true
          end
        end
      RUBY
    end
  end
end
