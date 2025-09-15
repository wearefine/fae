require 'mini_magick'
module Fae
  class UtilitiesController < ApplicationController

    def toggle
      klass = params[:object].gsub('__', '/').classify
      if can_toggle(klass, params[:attr])
        klass = klass.constantize
        klass.find(params[:id]).toggle(params[:attr]).save(validate: false)
        render body: nil
      else
        render body: nil, status: :unauthorized
      end
    end

    def sort
      if request.xhr?
        ids = params[params[:object]]
        klass = params[:object].gsub('fae_', 'fae/').gsub('__', '/').classify.constantize
        items = klass.find(ids)
        items.each do |item|
          position = ids.index(item.id.to_s) + 1
          item.update_attribute(:position, position)
        end
      end
      render body: nil
    end

    def language_preference
      if params[:language].present? && (params[:language] == 'all' || Fae.languages.has_key?(params[:language].to_sym))
        current_user.update_column(:language, params[:language])
      end
      render body: nil
    end

    def global_search
      if params[:query].present? && params[:query].length > 2
        search_locals = { navigation_items: @fae_navigation.search(params[:query]), records: records_by_display_name(params[:query]) }
      else
        search_locals = { show_nav: true }
      end
      render partial: 'global_search_results', locals: search_locals
    end

    def translate_text
      en_text = params['translation_text']['en_text']
      language = params['translation_text']['language']

      resp = translate_request(language, en_text)

      if !resp.kind_of?(Array) && resp['error']
        render json: [error_text: resp['error']['message']]
      else
        render json: [translated_text: resp.first['translations'].first['text']]
      end
    end
    
    def generate_alt
      if params[:image_id].present?
        path_or_url = :url
        path_or_url = :path if Rails.env.development?
        image = Fae::Image.find(params[:image_id])&.asset&.send(path_or_url)
        image = MiniMagick::Image.open(image)
      else
        image_data = Base64.decode64(params[:image].split(',').last)
        image = MiniMagick::Image.read(image_data)
      end
      image.resize "500x500"

      resized_image_data = Base64.encode64(image.to_blob)
      to_describe = "data:image/#{image.type.downcase};base64,#{resized_image_data}"
      resp = Fae::OpenAiApi.new.describe_image(to_describe)
      Rails.logger.info("Generated alt: #{resp}")
      render json: resp
    end

    private

    def can_toggle(klass, attribute)
      # check if class exists and convert
      return false unless Object.const_defined?(klass)
      klass = klass.constantize

      # allow admins to toggle Fae::User#active
      return true if klass == Fae::User && attribute == 'active' && current_user.super_admin_or_admin?

      # restrict models that only super admins can toggle
      restricted_classes = %w(Fae::User Fae::Role Fae::Option Fae::Change)
      return false if restricted_classes.include?(klass.name.to_s) && !current_user.super_admin?

      # restrict to only other boolean fields
      return false unless klass.columns_hash[attribute].type == :boolean

      true
    end

    def translate_request(language, en_text)
      if Rails.env.test?
        return [
                {
                  'detectedLanguage' => {
                    'language' => 'en',
                    'score' => 1.0
                  },
                  'translations' => [
                    {
                      'text' => "Bob Ross est l'homme.",
                      'to' => 'fr-CA'
                    }
                  ]
                }
              ]
      else
        subscription_key = ENV['TRANSLATOR_TEXT_SUBSCRIPTION_KEY']
        region = ENV['TRANSLATOR_TEXT_REGION']
        endpoint = 'https://api.cognitive.microsofttranslator.com'
        path = '/translate?api-version=3.0'

        language_params = "&to=#{language}"

        uri = URI (endpoint + path + language_params)

        content = '[{"Text" : "' + en_text + '"}]'

        request = Net::HTTP::Post.new(uri)
        request['Content-type'] = 'application/json'
        request['Content-length'] = content.length
        request['Ocp-Apim-Subscription-Key'] = subscription_key
        request['Ocp-Apim-Subscription-Region'] = region
        request['X-ClientTraceId'] = SecureRandom.uuid
        request.body = content

        response = Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
          http.request request
        end

        JSON.parse(response.body.force_encoding('utf-8'))
      end
    end

    def records_by_display_name(query)
      records = []
      all_models.each do |m|
        records += m.fae_search(query) if m.respond_to?(:fae_search)
      end
      records
    end

  end
end
