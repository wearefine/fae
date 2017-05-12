# mocking rails-controller-testing to allow us to keep it in our Gemfile to use Guard/Rspec
# while still supporting Rails 4.1 in Appraisals
Gem::Specification.new do |s|
  s.name        = 'rails-controller-testing'
  s.version     = '0.0.0'
  s.summary     = "A mock of rails-controller-testing"
  s.authors     = ['FINE']
end
