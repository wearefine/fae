require 'uri'

module Judge
  module Controller

    def validation(params)
      params = normalized_params(params)
      if params_present?(params) && params_exposed?(params)
        Validation.new(params)
      else
        NullValidation.new(params)
      end
    end

    private

      REQUIRED_PARAMS = %w{klass attribute value kind}
      CONDITIONAL_PARAMS = {kind: ['uniqueness', :original_value]}

      def params_exposed?(params)
        Judge.config.exposed?(params[:klass], params[:attribute])
      end

      def params_present?(params)
        required_params_present?(params) && conditional_params_present?(params)
      end

      def required_params_present?(params)
        REQUIRED_PARAMS.all? {|s| params.key? s} && params.values_at(*REQUIRED_PARAMS).all?
      end

      def conditional_params_present?(params)
        CONDITIONAL_PARAMS.each do |required_param, constraint|
          if params[required_param] == constraint.first
            return false unless params[constraint.last]
          end
        end
      end

      def normalized_params(params)
        parser = URI::Parser.new
        params = params.dup.keep_if {|k| REQUIRED_PARAMS.include?(k) || (k == 'original_value' && params[:kind] == 'uniqueness')}
        params[:klass]     = find_klass(params[:klass]) if params[:klass]
        params[:attribute] = params[:attribute].to_sym  if params[:attribute]
        params[:value]     = parser.unescape(params[:value]) if params[:value]
        params[:kind]      = params[:kind].to_sym       if params[:kind]
        params[:original_value] = parser.unescape(params[:original_value]) if params[:original_value]
        params
      end

      def find_klass(name)
        Module.const_get(name.classify)
      rescue NameError
        nil
      end

  end
end