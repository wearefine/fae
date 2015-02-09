require 'rails_helper'

describe Fae::ApplicationController do

  describe 'concerns' do
    it 'should allow instance methods through Fae::ApplicationControllerConcern' do
      expect(described_class.new.instance_says_what).to eq('Fae::ApplicationController instance: what?')
    end

    it 'should allow class methods through Fae::ApplicationController' do
      expect(described_class.class_says_what).to eq('Fae::ApplicationController class: what?')
    end
  end

end
