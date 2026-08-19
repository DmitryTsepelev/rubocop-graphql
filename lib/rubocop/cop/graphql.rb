# frozen_string_literal: true

module RuboCop
  module Cop
    # Cops for the `GraphQL` department. The department's cops are
    # registered for lazy loading and their files are loaded on demand.
    module GraphQL
      extend LazyLoader

      register_cop :ArgumentDescription, "#{__dir__}/graphql/argument_description"
      register_cop :ArgumentName, "#{__dir__}/graphql/argument_name"
      register_cop :ArgumentUniqueness, "#{__dir__}/graphql/argument_uniqueness"
      register_cop :ContextWriteInType, "#{__dir__}/graphql/context_write_in_type"
      register_cop :DefaultForOptionalArgument, "#{__dir__}/graphql/default_for_optional_argument"
      register_cop :DisallowedTypes, "#{__dir__}/graphql/disallowed_types"
      register_cop :ExtractInputType, "#{__dir__}/graphql/extract_input_type"
      register_cop :ExtractType, "#{__dir__}/graphql/extract_type"
      register_cop :FieldDefinitions, "#{__dir__}/graphql/field_definitions"
      register_cop :FieldDescription, "#{__dir__}/graphql/field_description"
      register_cop :FieldHashKey, "#{__dir__}/graphql/field_hash_key"
      register_cop :FieldMethod, "#{__dir__}/graphql/field_method"
      register_cop :FieldName, "#{__dir__}/graphql/field_name"
      register_cop :FieldUniqueness, "#{__dir__}/graphql/field_uniqueness"
      register_cop :GraphqlName, "#{__dir__}/graphql/graphql_name"
      register_cop :LegacyDsl, "#{__dir__}/graphql/legacy_dsl"
      register_cop :MaxComplexitySchema, "#{__dir__}/graphql/max_complexity_schema"
      register_cop :MaxDepthSchema, "#{__dir__}/graphql/max_depth_schema"
      register_cop :MethodShadowedByResolverMethod, "#{__dir__}/graphql/method_shadowed_by_resolver_method"
      register_cop :MultipleFieldDefinitions, "#{__dir__}/graphql/multiple_field_definitions"
      register_cop :NotAuthorizedNodeType, "#{__dir__}/graphql/not_authorized_node_type"
      register_cop :NullabilityMismatch, "#{__dir__}/graphql/nullability_mismatch"
      register_cop :ResolverMethodLength, "#{__dir__}/graphql/resolver_method_length"
      register_cop :ObjectDescription, "#{__dir__}/graphql/object_description"
      register_cop :OrderedArguments, "#{__dir__}/graphql/ordered_arguments"
      register_cop :OrderedFields, "#{__dir__}/graphql/ordered_fields"
      register_cop :PrepareMethod, "#{__dir__}/graphql/prepare_method"
      register_cop :UnusedArgument, "#{__dir__}/graphql/unused_argument"
      register_cop :UnnecessaryArgumentCamelize, "#{__dir__}/graphql/unnecessary_argument_camelize"
      register_cop :UnnecessaryFieldAlias, "#{__dir__}/graphql/unnecessary_field_alias"
      register_cop :UnnecessaryFieldCamelize, "#{__dir__}/graphql/unnecessary_field_camelize"
      register_cop :UselessMethodOption, "#{__dir__}/graphql/useless_method_option"
    end
  end
end
