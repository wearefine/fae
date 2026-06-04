module FieldFailoverable
  extend ActiveSupport::Concern

  included do

		def derived_seo_title
			if self.class.superclass.to_s.include?('Fae::StaticPage')
				return seo_title_content if seo_title_content.present?
				return "#{failover_seo_title} | #{website_name}"
			else
				return seo_title if self.try(:seo_title).present?
				return "#{failover_seo_title} | #{website_name}"
			end
		end

		def derived_seo_description
			if self.class.superclass.to_s.include?('Fae::StaticPage')
				return seo_description_content if seo_description_content.present?
			else
				return seo_description if self.try(:seo_description).present?
			end
		end

		def derived_social_media_title
			if self.class.superclass.to_s.include?('Fae::StaticPage')
				return social_media_title_content if social_media_title_content.present?
				return seo_title_content if seo_title_content.present?
				return "#{failover_seo_title} | #{website_name}"
			else
				return social_media_title if self.try(:social_media_title).present?
				return seo_title if self.try(:seo_title).present?
				return "#{failover_seo_title} | #{website_name}"
			end
		end

		def derived_social_media_description
			if self.class.superclass.to_s.include?('Fae::StaticPage')
				return social_media_description_content if social_media_description_content.present?
				return seo_description_content if seo_description_content.present?
			else
				return social_media_description if self.try(:social_media_description).present?
				return seo_description if self.try(:seo_description).present?
			end
		end

		def derived_social_media_image
			if self.respond_to?(:social_media_image)
				return social_media_image if asset_and_url_present?(social_media_image)
				global_content = GlobalContentPage.instance
				return global_content.social_media_image if asset_and_url_present?(global_content.social_media_image)
			end
		end

		def asset_and_url_present?(asset_object)
		  asset_object.present? && asset_object.asset.url.present?
		end

		def website_name
			GlobalContentPage.instance.website_name_content
		end

  end

end