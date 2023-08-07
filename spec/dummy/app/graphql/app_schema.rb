class AppSchema < GraphQL::Schema
  mutation(Types::MutationType)
  query(Types::QueryType)

  # This is GraphQL-Ruby boilerplate stuff

  # # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  # use GraphQL::Dataloader

  # # GraphQL-Ruby calls this when something goes wrong while running a query:
  # def self.type_error(err, context)
  #   # if err.is_a?(GraphQL::InvalidNullError)
  #   #   # report to your bug tracker here
  #   #   return nil
  #   # end
  #   super
  # end

  # # Union and Interface Resolution
  # def self.resolve_type(abstract_type, obj, ctx)
  #   # TODO: Implement this method
  #   # to return the correct GraphQL object type for `obj`
  #   raise(GraphQL::RequiredImplementationMissingError)
  # end

  # # Stop validating when it encounters this many errors:
  # validate_max_errors(100)
end
