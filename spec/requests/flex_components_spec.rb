require 'rails_helper'

RSpec.describe 'ComponentPage Query', type: :request do
  it 'returns the correct data' do
    post '/api', params: {
      query: <<-GRAPHQL
        {
          componentsPage {
            flexComponents {
              instance {
                __typename
                ... on HeroComponent {
                  title
                }
                ... on TextComponent {
                  name
                }
              }
            }
          }
        }
      GRAPHQL
    }

    json = JSON.parse(response.body)

    # Check that the response has the correct structure
    expect(json).to match({
      'data' => {
        'componentsPage' => {
          'flexComponents' => Array
        }
      }
    })

    # Check that each flexComponent has an instance with the correct fields
    json['data']['componentsPage']['flexComponents'].each do |flex_component|
      instance = flex_component['instance']
      expect(instance).to include('__typename')

      case instance['__typename']
      when 'HeroComponent'
        expect(instance).to include('title')
      when 'TextComponent'
        expect(instance).to include('name')
      end
    end
  end
end