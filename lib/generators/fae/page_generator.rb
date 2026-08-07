require_relative 'base_generator'
module Fae
  class PageGenerator < Fae::BaseGenerator
    desc 'Deprecated legacy content_blocks page generator'

    def go
      raise Thor::Error, 'fae:page has been removed. Use rails g fae:scaffold PageName ... --static-page=true.'
    end
  end
end
