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

  context "when argument uses InputType" do
    it "does not count InputType arguments toward the max" do
      expect_no_offenses(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: true
          argument :user_attributes, UserAttributesInputType, required: true
        end
      RUBY
    end

    it "does not count Input arguments toward the max" do
      expect_no_offenses(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: true
          argument :user_attributes, UserAttributesInput, required: true
        end
      RUBY
    end

    it "does not count namespaced InputType arguments toward the max" do
      expect_no_offenses(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: true
          argument :cancellation_options, Types::ContractCancellationOptionsInput, required: true
        end
      RUBY
    end

    it "does not count InputType arguments when type is on different line" do
      expect_no_offenses(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :email, String, required: true
          argument :cancellation_options,
                   Types::ContractCancellationOptionsInput,
                   required: false,
                   description: "Options for canceling the contract being replaced."
        end
      RUBY
    end

    it "still registers offense when non-InputType arguments exceed max" do
      expect_offense(<<~RUBY)
        class UpdateUser < BaseMutation
          argument :uuid, ID, required: true
          argument :first_name, String, required: true
          argument :last_name, String, required: true
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Consider moving arguments to a new input type
          argument :user_attributes, UserAttributesInputType, required: true
        end
      RUBY
    end
  end
end
