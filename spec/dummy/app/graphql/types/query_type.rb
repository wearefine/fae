# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject

    field :nested_tables_in_form_page, Types::NestedTablesInFormPageType, null: true do
      description "Returns the NestedTablesInForm Page instance"
    end

    def nested_tables_in_form_page
      NestedTablesInFormPage.instance
    end
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    # TODO: remove me
    field :test_field, String, null: false,
      description: "An example field added by the generator"
    def test_field
      "Hello World!"
    end

    field :components_page, Types::ComponentsPageType, null: true
    def components_page
      ComponentsPage.instance
    end
  end
end
