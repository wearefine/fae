module Fae
  class CrossModelUniquenessValidator < ActiveModel::EachValidator
    def validate_each(record, attribute, value)
      if options[:model].where(attribute => value).present?
        record.errors[attribute] << (options[:message] || "has already been taken in #{articlize(options[:model].to_s.downcase)}")
      end
    end

  private
    def articlize(params_word)
      %w(a e i o u).include?(params_word[0].downcase) ? "an #{params_word}" : "a #{params_word}"
    end
  end
end