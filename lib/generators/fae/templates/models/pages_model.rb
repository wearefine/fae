class <%= class_name %>Page < Fae::StaticPage
  include Fae::Concerns::Models::Base

  @slug = '<%= file_name %>'

  # required to set the has_one associations, the static controller will build these associations dynamically
  def fae_fields
    {
<% @attributes.each_with_index do |(attr, type), index| -%>
      <%= attr %>: <%= type %><%= index + 1 != @attributes.length ? ",\n" : "\n" -%>
<% end -%>
    }
  end

end