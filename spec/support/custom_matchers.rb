module CustomMatchers; end

Dir[Rails.root.join('spec/matchers/**/*.rb')].each { |f| require f }

RSpec.configure do |config|
  config.include CustomMatchers
end
