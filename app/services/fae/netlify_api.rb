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
      path = "sites/#{@site_id}/deploys?per_page=10"
      get_deploys_env_response(path)
    end

    def run_deploy(build_hook_type, current_user)
      hook = Fae.netlify[:build_hooks][build_hook_type]
      if hook.present?
        post("#{hook.url}?trigger_title=#{current_user.full_name.gsub(' ', '+')}+triggered+a+#{hook.name}+build")
        return true
      end
      false
    end

    def last_successful_any_deploy
      deploys = get_deploys || []
      the_deploy = nil
      deploys.each do |deploy|
        if deploy['state'] == 'ready'
          the_deploy = deploy
          break
        end
      end
      the_deploy
    end

    def last_successful_admin_deploy
      deploys = get_deploys || []
      the_deploy = nil
      deploys.each do |deploy|
        if deploy['state'] == 'ready' && deploy['commit_ref'].blank?
          the_deploy = deploy
          break
        end
      end
      the_deploy
    end

    def last_successful_production_deploy
      deploys = get_deploys || []
      the_deploy = nil
      deploys.each do |deploy|
        if deploy['state'] == 'ready' && deploy['context'] == 'production'
          the_deploy = deploy
          break
        end
      end
      the_deploy
    end

    def last_successful_staging_deploy
      deploys = get_deploys || []
      the_deploy = nil
      deploys.each do |deploy|
        if deploy['state'] == 'ready' && deploy['context'] == 'branch-deploy' && deploy['branch'] == 'staging'
          the_deploy = deploy
          break
        end
      end
      the_deploy
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

    def deploy_running?(deploy)
      %w(building processing enqueued uploading).include?(deploy['state'])
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