module Fae
  module FormHelper

    def test_method
      link_to('test', '#')
    end

    def fae_input(f, attribute, options={})
      f.input attribute, options
    end

  end
end
