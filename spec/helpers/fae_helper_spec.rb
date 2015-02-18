require 'rails_helper'

describe Fae::FaeHelper do

  it 'should allow parent app to add methods' do
    expect(helper.method_from_dummy).to eq('it works!')
  end

end