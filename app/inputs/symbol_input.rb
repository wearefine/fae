class SymbolInput < SimpleForm::Inputs::Base
  def input
    "<label for='#{object_name}_#{attribute_name}' class='#{options[:span_class]}'>#{options[:content_text]}</label>#{@builder.text_field(attribute_name)}".html_safe
  end
end