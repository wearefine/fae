class DateRangeInput < SimpleForm::Inputs::Base
  def input
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field :start_date, class: "daterangepicker"
      template.concat span_seperator
      template.concat @builder.text_field :end_date, class: "daterangepicker"
    end
  end

  def span_seperator
    template.content_tag(:span, class: 'daterangepicker-seperator') do
      template.concat "to"
    end
  end
end