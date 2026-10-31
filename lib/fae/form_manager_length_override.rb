module Fae
  # Lets Form Manager "Max Characters" settings replace the maximum of a model's
  # `length: { maximum: n }` validation. The model's value remains the default.
  module FormManagerLengthOverride

    module LengthValidator
      attr_accessor :fae_form_manager_override_applied

      def validate_each(record, attribute, value)
        return super if fae_form_manager_override_applied

        maximum = fae_maximum_override(record, attribute)
        return super if maximum.nil?

        fae_with_maximum(maximum).validate_each(record, attribute, value)
      end

      def fae_default_maximum
        options[:maximum] if options[:maximum].is_a?(Integer)
      end

      def fae_maximum_override(record, attribute)
        return if fae_default_maximum.nil?

        maximum = Fae::FormManager.max_length_override(record, attribute)
        maximum unless maximum == fae_default_maximum
      end

      def fae_effective_maximum(record, attribute)
        fae_maximum_override(record, attribute) || options[:maximum]
      end

      # Validator options are frozen, so build a copy with the new maximum
      def fae_with_maximum(maximum)
        validator = self.class.new(options.merge(maximum: maximum, attributes: attributes))
        validator.fae_form_manager_override_applied = true
        validator
      end
    end

    # Keeps Judge's client-side data-validate options and messages (and Fae's character counter) in sync with the override
    module JudgeValidator
      def initialize(object, method, amv)
        default_maximum = amv.try(:fae_default_maximum) if amv.kind == :length && Fae.use_form_manager

        if default_maximum.present?
          maximum = amv.fae_maximum_override(object, method)
          amv = amv.fae_with_maximum(maximum) if maximum.present?
        end

        super(object, method, amv)

        @options = @options.merge(fae_default_maximum: default_maximum) if default_maximum.present?
      end
    end

  end
end
