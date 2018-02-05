RSpec.configure do |config|
  # Include Devise
  config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Warden::Test::Helpers
  Devise.setup do |c|
    c.stretches = 1
  end
  config.before(:suite) do
    Warden.test_mode!
  end
  config.after(:each) do
    Warden.test_reset!
  end
end
