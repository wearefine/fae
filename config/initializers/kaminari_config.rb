Kaminari.configure do |config|
  config.default_per_page = Fae.per_page
  # config.max_per_page = nil
  config.window = 3
  # config.outer_window = 0
  config.left = 1
  config.right = 1
  # config.page_method_name = :page
  # config.param_name = :page
end
