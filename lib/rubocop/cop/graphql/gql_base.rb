# frozen_string_literal: true

module RuboCop
  module Cop
    module GraphQL
      class GQLBase < Base
        include RuboCop::GraphQL::NodePattern
        extend RuboCop::Cop::AutoCorrector

      end
    end
  end
end