module Fae
  class Engine < ::Rails::Engine
    isolate_namespace Fae
    require 'devise'
  end
end
