require 'rails_helper'

describe Fae::PublishHook do

  it { should validate_presence_of(:url) }
  it { should validate_presence_of(:environment) }

end