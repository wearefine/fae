require 'rails_helper'

describe Fae::User do

  it { should validate_presence_of(:name) }
  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:admin_environment) }

end
