# frozen_string_literal: true

# rubocop-graphql gem extension of RuboCop's ExpectOffense module.
#
# This mixin is the same as rubocop's ExpectOffense except the default
# filename contains 'graphql/'`
module ExpectOffense
  include RuboCop::RSpec::ExpectOffense

  DEFAULT_FILENAME = "graphql/example.rb"

  def expect_offense(source, filename = DEFAULT_FILENAME)
    super
  end

  def expect_no_offenses(source, filename = DEFAULT_FILENAME)
    super
  end
end
