require_relative 'base_generator'
module Fae
  class ModelGenerator < Fae::BaseGenerator
    source_root File.expand_path('../templates', __FILE__)

    def go
      generate_model
    end

  end
end