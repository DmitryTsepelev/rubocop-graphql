# frozen_string_literal: true

module RuboCop
  module GraphQL
    # Matches a variety of description formats commonly seen in Rails applications
    #
    #   description 'blah'
    #
    #   description "blah"
    #
    #   description <<~EOT
    #      blah
    #      bloop
    #   EOT
    #
    #   description <<-EOT.squish
    #      blah
    #      bloop
    #   EOT
    module DescriptionMethod
      extend RuboCop::NodePattern::Macros

      def_node_matcher :description_kwarg?, <<~PATTERN
        (send nil? :description
          {({str|dstr|const} ...)|(send const ...)|(send ({str|dstr} ...) _)})
      PATTERN

      def find_description_method(nodes)
        nodes.find { |kwarg| description_kwarg?(kwarg) }
      end
    end
  end
end
