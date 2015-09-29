module Fae::PageValidatable
  extend ActiveSupport::Concern

  def validators(page_class)
    self.class.validators_on(:content).keep_if { |amv| is_valid_validator?(amv, page_class) }
  end

  def validation_json(page_class)
    validators(page_class).map { |v| Judge::Validator.new(self, :content, v).to_hash }.to_json
  end

  def is_required?(page_class)
    required = false
    validators(page_class).each do |amv|
      required = true if amv.class.name['PresenceValidator']
    end
    required
  end

  private

  def is_valid_validator?(amv, page_class)
    amv.options[:if].blank? || amv.options[:if] == "is_#{page_class.name.underscore}_#{attached_as}?".to_sym
  end

end
