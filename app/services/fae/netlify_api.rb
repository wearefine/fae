require 'net/http'

module Fae
  class NetlifyApi

    def initialize()
      @netlify_api_user   = Fae.netlify[:api_user]
      @netlify_api_token  = Fae.netlify[:api_token]
      @site               = Fae.netlify[:site]
      @site_id            = Fae.netlify[:site_id]
      @endpoint_base      = Fae.netlify[:api_base]
      @logger             = Logger.new(Rails.root.join('log', 'netlify_api.log'))
    end

    def get_deploys
      path = "sites/#{@site_id}/deploys?per_page=15"
      get_deploys_env_response(path)
    end

    def run_deploy(deploy_hook_type, current_user)
      hook = Fae::DeployHook.find_by_environment(deploy_hook_type)
      if hook.present?
        post("#{hook.url}?trigger_title=#{current_user.full_name.gsub(' ', '+')}+triggered+a+#{deploy_hook_type.titleize}+deploy.")
        return true
      end
      false
    end

    def get_last_deploy_time
      deploys = get_deploys
      return Time.now if deploys.blank?
      deploys.first['updated_at']
    end

    private

    def get(endpoint)
      begin
        uri = URI.parse(endpoint)
        request = Net::HTTP::Get.new(uri)
        set_headers(request)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
          http.request(request)
        }
        if response.is_a?(Net::HTTPSuccess)
          return JSON.parse(response.body) if response.body.present?
        else
          @logger.info "\n"
          @logger.info "Get returned non-success code: #{response.code}"
          @logger.info "Endpoint: #{endpoint}"
          @logger.info "Body: #{response.body}" if response.body.present?
        end
      rescue Exception => e
        @logger.info "\n"
        @logger.info "Get failed"
        @logger.info "Endpoint: #{endpoint}"
        @logger.info "Reason: #{e}"
      end
    end

    def post(endpoint, params = nil)
      begin
        uri = URI.parse(endpoint)
        request = Net::HTTP::Post.new(uri)
        set_headers(request)
        request.body = params.to_json
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
          http.request(request)
        }
        if response.is_a?(Net::HTTPSuccess)
          return JSON.parse(response.body) if response.body.present?
        else
          @logger.info "\n"
          @logger.info "Post returned non-success code: #{response.code}"
          @logger.info "Endpoint: #{endpoint}"
          @logger.info "Params: #{params}"
          @logger.info "Body: #{response.body}" if response.body.present?
        end
      rescue Exception => e
        @logger.info "\n"
        @logger.info "Post failed"
        @logger.info "Endpoint: #{endpoint}"
        @logger.info "Params: #{params}"
        @logger.info "Reason: #{e}"
      end
    end

    def set_headers(request)
      request['User-Agent'] = "#{@site} (#{@netlify_api_user})"
      request['Authorization'] = "Bearer #{@netlify_api_token}"
    end

    def get_deploys_env_response(path)
      return get "#{@endpoint_base}#{path}" unless Rails.env.test?
      [
        {
          "state"=>"building",
          "name"=>"building-test",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>nil,
          "branch"=>"staging",
          "title"=>"Staging building",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"branch-deploy",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"processing",
          "name"=>"processing-test",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>nil,
          "branch"=>"staging",
          "title"=>"Staging processing",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"branch-deploy",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"ready",
          "name"=>"complete-test",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>'string',
          "branch"=>"staging",
          "title"=>"Staging complete",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"branch-deploy",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"ready",
          "name"=>"admin-test",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>nil,
          "branch"=>"staging",
          "title"=>"Staging admin complete",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"branch-deploy",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"error",
          "name"=>"error-test",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>'Error!',
          "commit_ref"=>nil,
          "branch"=>"staging",
          "title"=>"FINE admin triggered a Staging build",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"branch-deploy",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"ready",
          "name"=>"fae-dummy",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>nil,
          "branch"=>"master",
          "title"=>"A production build",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"production",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
        {
          "state"=>"ready",
          "name"=>"fae-dummy",
          "created_at"=>"2021-10-22T14:56:18.163Z",
          "updated_at"=>"2021-10-22T14:57:55.905Z",
          "error_message"=>nil,
          "commit_ref"=>nil,
          "branch"=>"master",
          "title"=>"Another production build",
          "review_url"=>nil,
          "published_at"=>nil,
          "context"=>"production",
          "deploy_time"=>93,
          "committer"=>nil,
          "skipped_log"=>nil,
          "manual_deploy"=>false,
        },
      ]
    end

  end
end