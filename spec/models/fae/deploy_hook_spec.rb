require 'rails_helper'

describe Fae::DeployHook do

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:environment) }

end