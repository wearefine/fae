require 'net/http'

module Fae
  class NetlifyApi

    def initialize()
      @netlify_api_user   = Fae.netlify_api_user
      @netlify_api_token  = Fae.netlify_api_token
      @site               = Fae.netlify_site
      @site_id            = Fae.netlify_site_id
      @endpoint_base      = Fae.netlify_api_base
      @logger             = Logger.new(Rails.root.join('log', 'netlify_api.log'))
    end

    def get_sites
      path = 'sites/'
      get "#{@endpoint_base}#{path}"
    end

    def get_deploys
      path = "sites/#{@site_id}/deploys"
      get "#{@endpoint_base}#{path}"
    end

    def run_deploy(publish_hook_id, current_user)
      hook = PublishHook.find_by_id(publish_hook_id)
      if hook.present?
        #post("#{hook.url}?trigger_title=J deploy test")
        post("#{hook.url}?trigger_title=#{current_user.full_name.gsub(' ', '+')}+triggered+a+#{hook.name}+build")
        return true
      end
      false
    end

    def current_deploy
      deploys = get_deploys
      return if deploys.blank?
      the_deploy = nil
      deploys.each{ |deploy| the_deploy = deploy if deploy['state'] == 'building' }
      the_deploy
    end

    # def create_site_build
    #   path = "sites/#{@site_id}/builds"
    #   post "#{@endpoint_base}#{path}", {}
    # end

    def prod_deploy
      hook = 'https://api.netlify.com/build_hooks/614b5d93745aeefacb1a7fcb'
      # RestClient.post "#{hook.url}?trigger_title=#{current_user.full_name.gsub(' ', '+')}+triggered+a+#{params['environment']}+build", {}.to_json, {}
      post "#{hook}?trigger_title=J testing API build", {}.to_json
    end

    def last_successful_deploy
      deploys = get_deploys
      if deploys.present?
        deploys.each{ |deploy| return deploy if deploy['state'] == 'ready' }
      end
    end

    private

    def get(endpoint, params = nil)
      #begin
        puts endpoint
        uri = URI.parse(endpoint)
        @request = Net::HTTP::Get.new(uri)
        set_headers(@request)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
          http.request(@request)
        }
        return JSON.parse(response.body) if response.present? && response.body.present?
      #rescue Exception => e
        @logger.info "\n"
        @logger.info "Failed getting on #{DateTime.now} to #{endpoint}"
        @logger.info "Params: #{params}"
        @logger.info "Reason: #{e}"
      #end
    end

    def post(endpoint, params = nil)
      #begin
        puts endpoint
        uri = URI.parse(endpoint)
        @request = Net::HTTP::Post.new(uri)
        set_headers(@request)
        @request.body = params.to_json
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
          http.request(@request)
        }
        return JSON.parse(response.body) if response.present? && response.body.present?
      #rescue Exception => e
        # @logger.info "\n"
        # @logger.info "Failed posting on #{DateTime.now} to #{endpoint}"
        # @logger.info "Params: #{params}"
        # @logger.info "Reason: #{e}"
      #end
    end

    def set_headers(request)
      request['User-Agent'] = "#{@site} (#{@netlify_api_user})"
      request['Authorization'] = "Bearer #{@netlify_api_token}"
    end

  end
end