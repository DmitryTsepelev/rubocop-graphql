# frozen_string_literal: true

RSpec.describe RuboCop::Cop::GraphQL::PrepareMethod, :config do
  let(:config) do
    RuboCop::Config.new(
      "GraphQL/PrepareMethod" => {
        "EnforcedStyle" => nil
      }
    )
  end

  context "when there is a block" do
    it "registers an offense when the block is declared directly" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: ->(input, context, type: check_type_from_enum) do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using prepare lambdas, use prepare: :method_name or prepare: "method_name" instead.
              PREPARE.call(input, context, type)
            end
        end
      RUBY
    end

    it "registers offense when prepare block has a lambda defined via a constant" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: PREPARE
                     ^^^^^^^ Avoid using prepare lambdas, use prepare: :method_name or prepare: "method_name" instead.
        end
      RUBY
    end
  end

  context "when the prepare argument uses a method name" do
    it "no offense when prepare block has a method defined as a symbol" do
      expect_no_offenses(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: :prepare_method
        end
      RUBY
    end

    it "no offense when prepare block has a method defined as a string" do
      expect_no_offenses(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: "prepare_method"
        end
      RUBY
    end
  end

  context "when the EnforcedStyle is string" do
    let(:config) do
      RuboCop::Config.new(
        "GraphQL/PrepareMethod" => {
          "EnforcedStyle" => "string"
        }
      )
    end

    it "registers an offense when the block is declared directly" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: ->(input, context, type: check_type_from_enum) do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using prepare lambdas, use prepare: "method_name" instead.
              PREPARE.call(input, context, type)
            end
        end
      RUBY
    end

    it "registers offense when prepare argument has a method defined as a symbol" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: :prepare_method
                     ^^^^^^^^^^^^^^^ Avoid using prepare symbols, use prepare: "prepare_method" instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: "prepare_method"
        end
      RUBY
    end

    it "no offense when prepare block has a method defined as a string" do
      expect_no_offenses(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: "prepare_method"
        end
      RUBY
    end
  end

  context "when the EnforcedStyle is symbol" do
    let(:config) do
      RuboCop::Config.new(
        "GraphQL/PrepareMethod" => {
          "EnforcedStyle" => "symbol"
        }
      )
    end

    it "registers an offense when the block is declared directly" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: ->(input, context, type: check_type_from_enum) do
                     ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Avoid using prepare lambdas, use prepare: :method_name instead.
              PREPARE.call(input, context, type)
            end
        end
      RUBY
    end

    it "registers offense when prepare block has a method defined as a string" do
      expect_offense(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: "prepare_method"
                     ^^^^^^^^^^^^^^^^ Avoid using prepare string, use prepare: :prepare_method instead.
        end
      RUBY

      expect_correction(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: :prepare_method
        end
      RUBY
    end

    it "no offense when prepare block has a method defined as a symbol" do
      expect_no_offenses(<<~RUBY)
        class CheckAlertSourceUsageCreate
          public_argument :input,
            Types::CheckAlertSourceUsageCreateInput,
            Types.t("check_alert_source_usage_create_input", "self"),
            required: true,
            prepare: prepare_method
        end
      RUBY
    end
  end
end
