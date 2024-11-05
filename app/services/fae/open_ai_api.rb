module Fae
  class OpenAiApi

    def initialize
    end
  
    def describe_image(url = nil)
      messages = [
        { "type": "text", "text": "Describe this image in one sentence." },
        { "type": "image_url",
          "image_url": {
            "url": "#{url}",
          },
        }
      ]
      begin
        result = {
          success: false,
          message: 'An error occurred while processing the image description.',
          content: nil
        }
        # Mock the response in test environment
        if Rails.env.test?
          response = {"id"=>"chatcmpl-APuHAeHiHlOyMM95tW1A3mPMvFCrk", "object"=>"chat.completion", "created"=>1730737888, "model"=>"gpt-4o-mini-2024-07-18", "choices"=>[{"index"=>0, "message"=>{"role"=>"assistant", "content"=>"A playful beagle puppy is lying down and chewing on a dry leaf.", "refusal"=>nil}, "logprobs"=>nil, "finish_reason"=>"stop"}], "usage"=>{"prompt_tokens"=>8514, "completion_tokens"=>15, "total_tokens"=>8529, "prompt_tokens_details"=>{"cached_tokens"=>0}, "completion_tokens_details"=>{"reasoning_tokens"=>0}}, "system_fingerprint"=>"fp_9b78b61c52"}
        else
          @client = ::OpenAI::Client.new(
            access_token: Fae.open_ai_api_key,
            log_errors: Rails.env.development? # This will leak potentially sensitive information to the logs in production
          )
          response = @client.chat(
            parameters: {
              model: "gpt-4o-mini",
              messages: [{ role: "user", content: messages}],
            }
          )
        end
        OpenAiApiCall.create(
          call_type: "describe_image",
          tokens: response.dig("usage", "total_tokens")
        )
        content = response.dig("choices", 0, "message", "content")
        if content.present?
          result[:success] = true
          result[:message] = ''
          result[:content] = content
        end
        result
      rescue => exception
        Rails.logger.error("Error in describe_image: #{exception.message}")
        Rails.logger.error(exception.backtrace.join("\n"))
        result
      end
    end
  
  end
end