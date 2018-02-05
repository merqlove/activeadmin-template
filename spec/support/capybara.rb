require 'capybara/rails'
require 'capybara/rspec'

if ENV['WEBDRIVER'] == 'selenium'
  require 'selenium-webdriver'
  Capybara.default_driver = :selenium
  Capybara.register_driver :selenium do |app|
    Capybara::Selenium::Driver.new(app, :browser => :chrome)
  end
else
  require 'capybara/poltergeist'
  Capybara.javascript_driver = :poltergeist
  Capybara.register_driver :poltergeist do |app|
    options = {
      js_errors: true,
      timeout: 120,
      debug: false,
      phantomjs_options: %w(--load-images=no --disk-cache=false),
      inspector: true
    }
    Capybara::Poltergeist::Driver.new(app, options)
  end
end

Capybara.configure do |config|
  config.always_include_port = true
  config.ignore_hidden_elements = true
end

RSpec.configure do |config|
  if ENV['WEBDRIVER'] == 'selenium'
    config.before(:each, type: :feature) do
      WebMock.disable_net_connect!(:allow_localhost => true)
    end
  end
end