class RadioCollectionInput < SimpleForm::Inputs::CollectionRadioButtonsInput

  def input(wrapper_options)
    label_method, value_method = detect_collection_methods

    @builder.send("collection_radio_buttons",
      attribute_name, collection, value_method, label_method,
      input_options, input_html_options, &collection_block_for_nested_boolean_style
    )
  end

  protected

  def build_nested_boolean_style_item_tag(collection_builder)
    collection_builder.radio_button + "<span class='radio_collection-bullet'></span>".html_safe + collection_builder.text
  end
end