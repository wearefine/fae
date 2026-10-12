require 'capybara/cuprite'

Capybara.register_driver(:cuprite) do |app|
  Capybara::Cuprite::Driver.new(
    app,
    window_size: [1680, 1050],
    timeout: 15,
    process_timeout: 30,
    # Set JS_ERRORS=true to fail specs on uncaught JS exceptions (useful when debugging)
    js_errors: ENV['JS_ERRORS'] == 'true',
    headless: ENV['HEADLESS'] != 'false',
    # Chrome refuses to run as root (e.g. in docker) without disabling the sandbox, and
    # docker's 64MB default /dev/shm is too small for Chrome's shared memory
    browser_options: { 'no-sandbox' => nil, 'disable-dev-shm-usage' => nil },
    url_blacklist: [%r{\Ahttps?://(?!(127\.0\.0\.1|localhost|secure\.gravatar\.com))}]
  )
end

Capybara.javascript_driver = :cuprite

Capybara::Screenshot.register_driver(:cuprite) do |driver, path|
  driver.save_screenshot(path, full: true)
end
