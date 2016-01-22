# moved to app/models/concerns/fae/base_model_concern.rb
# keep for backwards compatibility
module Fae::Concerns::Models::Base
  extend ActiveSupport::Concern

  included do
    include Fae::BaseModelConcern
    # include ActiveModel::Serialization
    # include ActiveModel::Serialization
    # include Fae::BaseSerializer
    # include Fae::BaseSerializerConcern
  end

end
