require 'rails_helper'

describe Fae::File do

  describe 'concerns' do
    it 'should allow instance methods through Fae::FileConcern' do
      file = Fae::File.new
      expect(file.instance_says_what).to eq('Fae::File instance: what?')
    end

    it 'should allow class methods through Fae::FileConcern' do
      expect(Fae::File.class_says_what).to eq('Fae::File class: what?')
    end
  end

end