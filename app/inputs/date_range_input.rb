class DateRangeInput < SimpleForm::Inputs::Base
  def input(wrapper_options)
    start_date = options[:start_date] || :start_date
    end_date = options[:end_date] || :end_date
    template.content_tag(:div, class: 'input-group date form_datetime') do
      template.concat @builder.text_field start_date, class: "daterangepicker js-start_date"
      template.concat span_seperator
      template.concat @builder.text_field end_date, class: "daterangepicker js-end_date"
    end
  end

  def span_seperator
    template.content_tag(:span, class: 'daterangepicker-seperator') do
      template.concat "to"
    end
  end
end