class <%= class_name.singularize %>Page < Fae::StaticPage

  @slug = '<%= file_name.singularize %>'

  # required to set the has_one associations, Fae::StaticPage will build these associations dynamically
  def self.fae_fields
    {
<% @attributes.each_with_index do |(attr, type), index| -%>
      <%= attr %>: <%= type %><%= index + 1 != @attributes.length ? ",\n" : "\n" -%>
<% end -%>
    }
  end

end