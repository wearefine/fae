# eventually usage:
# it "should return a result of 5" do
#   eventually { long_running_thing.result.should eq(5) }
# end
def eventually(options = {})
  timeout = options[:timeout] || 10
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

# Waits for jQuery animations (e.g. FCH.smoothScroll, slideUp) to finish so
# clicks aren't dispatched at coordinates that move mid-scroll.
def wait_for_animations
  eventually { expect(page.evaluate_script('window.jQuery ? jQuery(":animated").length : 0')).to eq(0) }
end
