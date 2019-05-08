class Types::<%= class_name %>PageType < Types::BaseObject

  graphql_name '<%= class_name %>Page'

  field :title, String, null: false
<% if @graphql_attributes.present? -%>
<% @graphql_attributes.each do |graphql_object| -%>
<% if graphql_object[:type]['Types::']  -%>
  field :<%= graphql_object[:attr] %>, <%= graphql_object[:type] %>, null: true
<% else -%>
  field :<%= graphql_object[:attr] %>, <%= graphql_object[:type] %>,
    null: true,
    method: :<%= graphql_object[:attr] %>_content
<% end -%>
<% end -%>
<% end -%>
end
