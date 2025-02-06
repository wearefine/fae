module Fae
  class OpenAiApiCall < ActiveRecord::Base
    include Fae::BaseModelConcern
    include Fae::OpenAiApiCallConcern
  end  
end