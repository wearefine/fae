require 'net/http'

module Fae
  class CloudflareApi

    def initialize()
      @cloudflare_account_id   = Fae.cloudflare[:account_id]
      @cloudflare_api_token    = Fae.cloudflare[:api_token]
      @project_name            = Fae.cloudflare[:project_name]
      @endpoint_base           = Fae.cloudflare[:api_base]
      @logger                  = Logger.new(Rails.root.join('log', 'cloudflare_api.log'))
    end

    def get_deploys
      path = "/accounts/#{@cloudflare_account_id}/pages/projects/#{@project_name}/deployments?per_page=15"
      restructure_deploy_data(get_deploys_env_response(path))
    end

    def run_deploy(deploy_hook_type, current_user = nil)
      # {"result"=>{"id"=>"d4e735b2-24e4-4565-ae6a-4057b8a45cb0"}, "success"=>true, "errors"=>[], "messages"=>[]}
      hook = DeployHook.find_by_environment(deploy_hook_type)
      if hook.present?
        response = post(hook.url)
        if response && response['result'].present?
          Deploy.create({
            user_id: current_user.id,
            user_name: current_user.full_name,
            external_deploy_id: response['result']['id']
          })
          return true
        end
      end
      false
    end

    private

    def get(endpoint, params = nil)
      begin
        uri = URI.parse(endpoint)
        request = Net::HTTP::Get.new(uri)
        set_headers(request)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) {|http|
          http.request(request)
        }
        return JSON.parse(response.body) if response.present? && response.body.present?
      rescue Exception => e
        @logger.info "\n"
        @logger.info "Failed getting on #{DateTime.now} to #{endpoint}"
        @logger.info "Params: #{params}"
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
        return JSON.parse(response.body) if response.present? && response.body.present?
      rescue Exception => e
        @logger.info "\n"
        @logger.info "Failed posting on #{DateTime.now} to #{endpoint}"
        @logger.info "Params: #{params}"
        @logger.info "Reason: #{e}"
      end
    end

    def set_headers(request)
      request['Authorization'] = "Bearer #{@cloudflare_api_token}"
    end

    # The FE JS was built against Netlify, rather than dirty up the works
    # with conditionals there, restructure the Cloudflare data as best we can here
    def restructure_deploy_data(response)
      ret = []
      if response && response['result'].present?
        response['result'].each do |deploy|
          ret << {
            state: set_state(deploy),
            title: pretty_title(deploy),
            updated_at: deploy['modified_on'],
            deploy_time: (deploy['modified_on'].to_time - deploy['created_on'].to_time).ceil,
            branch: nil,
            environment: deploy['environment'],
            latest_stage: "#{deploy['latest_stage']['name']}:#{deploy['latest_stage']['status']}"
          }
        end
      end
      ret
    end

    def set_state(deploy)
      case deploy['latest_stage']['status']
      when 'active'
        'running'
      when 'idle', 'canceled', 'success', 'skipped'
        'ready'
      when 'failure'
        'error'
      end
    end

    def pretty_title(deploy)
      our_deploy = Deploy.find_by_external_deploy_id(deploy['id'])
      case deploy['deployment_trigger']['type']
      when 'github:push'
        'FINE Dev Update'
      when 'deploy_hook'
        our_deploy.present? ? our_deploy.user_name : 'CMS Admin'
      when 'ad_hoc'
        'Cloudflare Admin'
      end
    end

    def get_deploys_env_response(path)
      #return get "#{@endpoint_base}#{path}" unless Rails.env.test?
      JSON.parse '{
        "result": [
          {
            "id": "a22ba3c8-5abd-4a76-a303-4ae995db04c5",
            "short_id": "a22ba3c8",
            "project_id": "b028b43f-61aa-423b-ba02-96e8326a8fb1",
            "project_name": "the-project",
            "environment": "production",
            "url": "https://a22ba3c8.the-project.pages.dev",
            "created_on": "2023-01-09T19:27:19.167091Z",
            "modified_on": "2023-01-09T19:30:39.82278Z",
            "latest_stage": {
              "name": "queued",
              "started_on": "2023-01-09T19:27:19.540553Z",
              "ended_on": "2023-01-09T19:30:39.82278Z",
              "status": "active"
            },
            "deployment_trigger": {
              "type": "deploy_hook",
              "metadata": {
                "branch": "main",
                "commit_hash": "4e59e7ced60950eb7f7c227ba9639df1f23f7f3c",
                "commit_message": "set up basic typogrpahy and color settings",
                "commit_dirty": false
              }
            },
            "stages": [
              {
                "name": "queued",
                "started_on": "2023-01-09T19:27:19.540553Z",
                "ended_on": "2023-01-09T19:30:39.82278Z",
                "status": "canceled"
              },
              {
                "name": "initialize",
                "started_on": null,
                "ended_on": null,
                "status": "idle"
              },
              {
                "name": "clone_repo",
                "started_on": null,
                "ended_on": null,
                "status": "idle"
              },
              {
                "name": "build",
                "started_on": null,
                "ended_on": null,
                "status": "idle"
              },
              {
                "name": "deploy",
                "started_on": null,
                "ended_on": null,
                "status": "idle"
              }
            ],
            "build_config": {
              "build_command": "nuxt generate",
              "destination_dir": ".output/public",
              "root_dir": "",
              "web_analytics_tag": null,
              "web_analytics_token": null
            },
            "source": {
              "type": "github",
              "config": {
                "owner": "wearefine",
                "repo_name": "the-project",
                "production_branch": "main",
                "pr_comments_enabled": false
              }
            },
            "env_vars": {},
            "compatibility_date": "2023-01-04",
            "compatibility_flags": [],
            "build_image_major_version": 1,
            "usage_model": null,
            "aliases": null,
            "is_skipped": false,
            "production_branch": "main"
          },
          {
            "id": "a53ea0d3-55b2-4e83-8e14-a0c56aaf8992",
            "short_id": "a53ea0d3",
            "project_id": "b028b43f-61aa-423b-ba02-96e8326a8fb1",
            "project_name": "the-project",
            "environment": "production",
            "url": "https://a53ea0d3.the-project.pages.dev",
            "created_on": "2023-01-06T23:22:43.872702Z",
            "modified_on": "2023-01-06T23:24:21.98746Z",
            "latest_stage": {
              "name": "deploy",
              "started_on": "2023-01-06T23:24:14.870791Z",
              "ended_on": "2023-01-06T23:24:21.98746Z",
              "status": "success"
            },
            "deployment_trigger": {
              "type": "deploy_hook",
              "metadata": {
                "branch": "main",
                "commit_hash": "4e59e7ced60950eb7f7c227ba9639df1f23f7f3c",
                "commit_message": "set up basic typogrpahy and color settings",
                "commit_dirty": false
              }
            },
            "stages": [
              {
                "name": "queued",
                "started_on": "2023-01-06T23:22:43.955603Z",
                "ended_on": "2023-01-06T23:22:43.943006Z",
                "status": "success"
              },
              {
                "name": "initialize",
                "started_on": "2023-01-06T23:22:43.943006Z",
                "ended_on": "2023-01-06T23:22:46.051188Z",
                "status": "success"
              },
              {
                "name": "clone_repo",
                "started_on": "2023-01-06T23:22:46.051188Z",
                "ended_on": "2023-01-06T23:22:48.11812Z",
                "status": "success"
              },
              {
                "name": "build",
                "started_on": "2023-01-06T23:22:48.11812Z",
                "ended_on": "2023-01-06T23:24:14.870791Z",
                "status": "success"
              },
              {
                "name": "deploy",
                "started_on": "2023-01-06T23:24:14.870791Z",
                "ended_on": "2023-01-06T23:24:21.98746Z",
                "status": "success"
              }
            ],
            "build_config": {
              "build_command": "nuxt generate",
              "destination_dir": ".output/public",
              "root_dir": "",
              "web_analytics_tag": null,
              "web_analytics_token": null
            },
            "source": {
              "type": "github",
              "config": {
                "owner": "wearefine",
                "repo_name": "the-project",
                "production_branch": "main",
                "pr_comments_enabled": false
              }
            },
            "env_vars": {},
            "compatibility_date": "2023-01-04",
            "compatibility_flags": [],
            "build_image_major_version": 1,
            "usage_model": null,
            "aliases": null,
            "is_skipped": false,
            "production_branch": "main"
          },
          {
            "id": "dd44fde8-0e80-42d7-adef-9d07f061bcbe",
            "short_id": "dd44fde8",
            "project_id": "b028b43f-61aa-423b-ba02-96e8326a8fb1",
            "project_name": "the-project",
            "environment": "production",
            "url": "https://dd44fde8.the-project.pages.dev",
            "created_on": "2023-01-04T20:45:47.639395Z",
            "modified_on": "2023-01-04T20:47:23.469307Z",
            "latest_stage": {
              "name": "deploy",
              "started_on": "2023-01-04T20:47:15.935184Z",
              "ended_on": "2023-01-04T20:47:23.469307Z",
              "status": "success"
            },
            "deployment_trigger": {
              "type": "github:push",
              "metadata": {
                "branch": "main",
                "commit_hash": "3aa8ce7eeb64f34a080872927310c9baf33d41f7",
                "commit_message": "adding homepage change to test deployments",
                "commit_dirty": false
              }
            },
            "stages": [
              {
                "name": "queued",
                "started_on": "2023-01-04T20:45:47.745947Z",
                "ended_on": "2023-01-04T20:45:47.710969Z",
                "status": "success"
              },
              {
                "name": "initialize",
                "started_on": "2023-01-04T20:45:47.710969Z",
                "ended_on": "2023-01-04T20:45:50.143946Z",
                "status": "success"
              },
              {
                "name": "clone_repo",
                "started_on": "2023-01-04T20:45:50.143946Z",
                "ended_on": "2023-01-04T20:45:52.343525Z",
                "status": "success"
              },
              {
                "name": "build",
                "started_on": "2023-01-04T20:45:52.343525Z",
                "ended_on": "2023-01-04T20:47:15.935184Z",
                "status": "success"
              },
              {
                "name": "deploy",
                "started_on": "2023-01-04T20:47:15.935184Z",
                "ended_on": "2023-01-04T20:47:23.469307Z",
                "status": "success"
              }
            ],
            "build_config": {
              "build_command": "nuxt generate",
              "destination_dir": ".output/public",
              "root_dir": "",
              "web_analytics_tag": null,
              "web_analytics_token": null
            },
            "source": {
              "type": "github",
              "config": {
                "owner": "wearefine",
                "repo_name": "the-project",
                "production_branch": "main",
                "pr_comments_enabled": false
              }
            },
            "env_vars": {},
            "compatibility_date": "2023-01-04",
            "compatibility_flags": [],
            "build_image_major_version": 1,
            "usage_model": null,
            "aliases": null,
            "is_skipped": false,
            "production_branch": "main"
          },
          {
            "id": "3550bf9e-6e6c-4d9b-b511-78010a3fc0e7",
            "short_id": "3550bf9e",
            "project_id": "b028b43f-61aa-423b-ba02-96e8326a8fb1",
            "project_name": "the-project",
            "environment": "production",
            "url": "https://3550bf9e.the-project.pages.dev",
            "created_on": "2023-01-04T18:10:49.467628Z",
            "modified_on": "2023-01-04T18:12:25.631178Z",
            "latest_stage": {
              "name": "deploy",
              "started_on": "2023-01-04T18:12:19.268697Z",
              "ended_on": "2023-01-04T18:12:25.631178Z",
              "status": "success"
            },
            "deployment_trigger": {
              "type": "github:push",
              "metadata": {
                "branch": "main",
                "commit_hash": "75d3d5299bb58e40b0dc970239455a89a3f95dc7",
                "commit_message": "updated .env file with MAIN_",
                "commit_dirty": false
              }
            },
            "stages": [
              {
                "name": "queued",
                "started_on": "2023-01-04T18:10:49.559194Z",
                "ended_on": "2023-01-04T18:10:49.545275Z",
                "status": "success"
              },
              {
                "name": "initialize",
                "started_on": "2023-01-04T18:10:49.545275Z",
                "ended_on": "2023-01-04T18:10:51.337071Z",
                "status": "success"
              },
              {
                "name": "clone_repo",
                "started_on": "2023-01-04T18:10:51.337071Z",
                "ended_on": "2023-01-04T18:10:53.481993Z",
                "status": "success"
              },
              {
                "name": "build",
                "started_on": "2023-01-04T18:10:53.481993Z",
                "ended_on": "2023-01-04T18:12:19.268697Z",
                "status": "success"
              },
              {
                "name": "deploy",
                "started_on": "2023-01-04T18:12:19.268697Z",
                "ended_on": "2023-01-04T18:12:25.631178Z",
                "status": "success"
              }
            ],
            "build_config": {
              "build_command": "nuxt generate",
              "destination_dir": ".output/public",
              "root_dir": "",
              "web_analytics_tag": null,
              "web_analytics_token": null
            },
            "source": {
              "type": "github",
              "config": {
                "owner": "wearefine",
                "repo_name": "the-project",
                "production_branch": "main",
                "pr_comments_enabled": false
              }
            },
            "env_vars": {},
            "compatibility_date": "2023-01-04",
            "compatibility_flags": [],
            "build_image_major_version": 1,
            "usage_model": null,
            "aliases": null,
            "is_skipped": false,
            "production_branch": "main"
          },
          {
            "id": "fb2276cb-448e-4406-91fd-daf5eb4c67ac",
            "short_id": "fb2276cb",
            "project_id": "b028b43f-61aa-423b-ba02-96e8326a8fb1",
            "project_name": "the-project",
            "environment": "production",
            "url": "https://fb2276cb.the-project.pages.dev",
            "created_on": "2023-01-04T18:08:28.91661Z",
            "modified_on": "2023-01-04T18:09:45.66599Z",
            "latest_stage": {
              "name": "deploy",
              "started_on": "2023-01-04T18:09:37.263399Z",
              "ended_on": "2023-01-04T18:09:45.66599Z",
              "status": "success"
            },
            "deployment_trigger": {
              "type": "ad_hoc",
              "metadata": {
                "branch": "main",
                "commit_hash": "0708a5e1a4e99bb18c9bf746f235b5166c662556",
                "commit_message": "intitial commit",
                "commit_dirty": false
              }
            },
            "stages": [
              {
                "name": "queued",
                "started_on": "2023-01-04T18:08:29.280247Z",
                "ended_on": "2023-01-04T18:08:29.271025Z",
                "status": "success"
              },
              {
                "name": "initialize",
                "started_on": "2023-01-04T18:08:29.271025Z",
                "ended_on": "2023-01-04T18:08:30.989558Z",
                "status": "success"
              },
              {
                "name": "clone_repo",
                "started_on": "2023-01-04T18:08:30.989558Z",
                "ended_on": "2023-01-04T18:08:33.077194Z",
                "status": "success"
              },
              {
                "name": "build",
                "started_on": "2023-01-04T18:08:33.077194Z",
                "ended_on": "2023-01-04T18:09:37.263399Z",
                "status": "success"
              },
              {
                "name": "deploy",
                "started_on": "2023-01-04T18:09:37.263399Z",
                "ended_on": "2023-01-04T18:09:45.66599Z",
                "status": "success"
              }
            ],
            "build_config": {
              "build_command": "nuxt generate",
              "destination_dir": ".output/public",
              "root_dir": "",
              "web_analytics_tag": null,
              "web_analytics_token": null
            },
            "source": {
              "type": "github",
              "config": {
                "owner": "wearefine",
                "repo_name": "the-project",
                "production_branch": "main",
                "pr_comments_enabled": false
              }
            },
            "env_vars": {},
            "compatibility_date": "2023-01-04",
            "compatibility_flags": [],
            "build_image_major_version": 1,
            "usage_model": null,
            "aliases": null,
            "is_skipped": false,
            "production_branch": "main"
          }
        ],
        "success": true,
        "errors": [],
        "messages": [],
        "result_info": {
          "page": 1,
          "per_page": 25,
          "count": 5,
          "total_count": 5
        }
      }'
    end

  end
end