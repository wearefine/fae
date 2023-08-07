require 'rails_helper'

describe 'graphql request' do

  it 'should make a graphql api request' do

    params = {
      "query" => "{
        testField
      }",
      "variables" => nil,
      "operationName" => nil,
    }
    post api_path(params)

    expect(response.body).to include("testField")
    expect(response.body).to include("Hello World!")
  end

end