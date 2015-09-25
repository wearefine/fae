module Fae::PageValidatable
  extend ActiveSupport::Concern

  def validation_json(page_class)
    validators = self.class.validators_on(:content)
    validators.keep_if { |amv| is_valid_validator?(amv, page_class) }
    validators.map { |v| Judge::Validator.new(self, :content, v).to_hash }.to_json
  end

  private

  def is_valid_validator?(amv, page_class)
    amv.options[:if].blank? || amv.options[:if] == "is_#{page_class.name.underscore}_#{attached_as}?".to_sym
  end

end
