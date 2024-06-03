class Types::FlexComponentUnionType < Types::BaseUnion

  graphql_name 'FlexComponentUnion'
  description "Resolves the type of Flex component."

  possible_types(Types::HeroComponentType, Types::TextComponentType, )

  def self.resolve_type(object, context)
    "Types::#{object.class.name}Type".constantize
  end
end