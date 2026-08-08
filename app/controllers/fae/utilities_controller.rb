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

      Rails.logger.info("Translation response: #{resp}")

      if !resp.kind_of?(Array) && resp['error']
        render json: [error_text: resp['error']['message']]
      else
        render json: [translated_text: resp.first['translations'].first['text']]
      end
    end
    
    def generate_alt
      if params[:image_id].present?
        fae_image = Fae::Image.find_by(id: params[:image_id])
        uploader = fae_image&.asset
        source = uploader&.path.presence || uploader&.url.presence

        if source.blank?
          render json: { success: false, message: 'Please upload an image before generating alt text.' }, status: :unprocessable_entity
          return
        end

        image = MiniMagick::Image.open(source)
      else
        if params[:image].blank?
          render json: { success: false, message: 'No image payload provided.' }, status: :unprocessable_entity
          return
        end

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

    # Manage ranked association items (create/destroy join records)
    # Used by fae_ranked_select to persist selections before form save
    def ranked_item
      join_class = params[:join_model].classify.constantize
      
      # Handle StaticPage specially - the actual class is Fae::StaticPage
      parent_class = if params[:parent_model] == 'StaticPage'
        Fae::StaticPage
      else
        params[:parent_model].classify.constantize
      end
      
      associated_class = params[:associated_model].classify.constantize
      
      parent = parent_class.find(params[:parent_id])
      associated_item = associated_class.find(params[:associated_id])
      
      # Determine the foreign key names
      # For StaticPage, the key is still 'static_page_id' (not 'fae_static_page_id')
      parent_key = "#{params[:parent_model].underscore}_id"
      associated_key = "#{params[:associated_model].underscore}_id"
      
      if params[:action_type] == 'add'
        # Find or create the join record
        join_record = join_class.find_or_create_by!(
          parent_key => parent.id,
          associated_key => associated_item.id
        )
        # Set position to end of list
        max_position = join_class.where(parent_key => parent.id).maximum(:position) || 0
        join_record.update(position: max_position + 1) if join_record.position.nil? || join_record.position == 0
        
        render json: { 
          success: true, 
          join_record_id: join_record.id,
          position: join_record.position
        }
      elsif params[:action_type] == 'remove'
        # Find and destroy the join record
        join_record = join_class.find_by(
          parent_key => parent.id,
          associated_key => associated_item.id
        )
        join_record&.destroy
        
        render json: { success: true }
      else
        render json: { success: false, error: 'Invalid action_type' }, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordNotFound => e
      render json: { success: false, error: e.message }, status: :not_found
    rescue => e
      render json: { success: false, error: e.message }, status: :unprocessable_entity
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
