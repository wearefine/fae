class Types::<%= class_name %>Type < Types::BaseObject

  graphql_name '<%= class_name %>'

  field :id, ID, null: false
<% @graphql_attributes.each do |grapql_object| -%>
  field :<%= grapql_object[:attr] %>, <%= grapql_object[:type] %>, null: true
<% end -%>
end
