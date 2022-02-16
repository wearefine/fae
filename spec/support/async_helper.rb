# eventually usage:
# it "should return a result of 5" do
#   eventually { long_running_thing.result.should eq(5) }
# end
def eventually(options = {})
  timeout = options[:timeout] || 5
  interval = options[:interval] || 0.2
  time_limit = Time.now + timeout
  loop do
    begin
      yield
    rescue *[RSpec::Expectations::ExpectationNotMetError, StandardError] => error
    end
    return if error.nil?
    raise error if Time.now >= time_limit
    sleep interval
  end
end
