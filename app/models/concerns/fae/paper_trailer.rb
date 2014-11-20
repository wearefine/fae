module Fae::PaperTrailer
  extend ActiveSupport::Concern

  included do
    has_paper_trail ignore: [:updated_at]
  end

end
