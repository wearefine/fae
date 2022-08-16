module Judge

  class ValidatorCollection

    include Enumerable

    attr_reader :validators, :object, :method

    def initialize(object, method)
      @object = object
      @method = method
      @validators = amvs.map { |amv| Judge::Validator.new(object, method, amv) }
    end

    def each(&block)
      validators.each do |v|
        block.call(v)
      end
    end

    def to_json
      validators.map { |v| v.to_hash }.to_json
    end

    protected

      UNSUPPORTED_OPTIONS = [:if, :on, :unless, :tokenizer, :scope, :case_sensitive]

      # returns an array of ActiveModel::Validations
      # starts with all Validations attached to method and removes one that are:
      #   ignored based on a config
      #   ConfirmationValidators, which are moved directly to the confirmation method
      #   unsupported by Judge
      # if it's a confirmation field, an AM::V like class is added to handle the confirmation validations
      def amvs
        # since the method that gets passed in here for associations comes in the form of the generated form attribute 
        # i.e. :wine_id or :acclaim_ids
        # object.class.validators_on(:wine_id) will fail since the active model validation is on :wine
        # this ensures that validations defined as 'validates :wine, presence: true' still get applied 
        # and client side error messages get generated 
        method_to_search = method
        regex_for_assocations = /_id|_ids/
        if method.to_s.match?(regex_for_assocations)
          parsed_method = method.to_s.gsub(regex_for_assocations, '');
          reflection = find_association_reflection(parsed_method)
          method_to_search = reflection.name if reflection
        end

        amvs = object.class.validators_on(method_to_search)
        amvs = amvs.reject { |amv| reject?(amv) || amv.class.name['ConfirmationValidator'] }
        amvs = amvs.reject { |amv| unsupported_options?(amv) && reject?(amv) != false } if Judge.config.ignore_unsupported_validators?
        amvs << Judge::ConfirmationValidator.new(object, method) if is_confirmation?

        amvs
      end

      def find_association_reflection(association)
        if object.class.respond_to?(:reflect_on_association)
          object.class.reflect_on_association(association) || object.class.reflect_on_association(association.pluralize)
        end
      end

      def unsupported_options?(amv)
        unsupported = !(amv.options.keys & UNSUPPORTED_OPTIONS).empty?
        return false unless unsupported
        # Apparently, uniqueness validations always have the case_sensitive option, even
        # when it is not explicitly used (in which case it has value true). Hence, we only
        # report the validation as unsupported when case_sensitive is set to false.
        unsupported = amv.options.keys & UNSUPPORTED_OPTIONS
        unsupported.length > 1 || unsupported != [:case_sensitive] || amv.options[:case_sensitive] == false
      end

      # decides whether to reject a validation based on the presence of the judge option.
      # return values:
      #   true  when :judge => :ignore is present in the options
      #   false when :judge => :force is present
      #   nil otherwise (e.g. when no :judge option or an unknown option is present)
      def reject?(amv)
        return unless [:force, :ignore].include?( amv.options[:judge] )
        amv.options[:judge] == :ignore
      end

      def is_confirmation?
        method.to_s['_confirmation']
      end

  end

end