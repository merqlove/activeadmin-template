RSpec.configure do |config|
  config.use_transactional_fixtures = false

  config.before(:example) do
    DatabaseCleaner.strategy =
      if RSpec.current_example.metadata[:js]
        :truncation
      else
        :transaction
      end
    ActiveRecord::Base.connection.increment_open_transactions if ActiveRecord::Base.connection.open_transactions < 0
    DatabaseCleaner.start unless RSpec.current_example.metadata[:nodb]
  end

  config.before(:example, type: :feature) do
    # :rack_test driver's Rack app under test shares database connection
    # with the specs, so we can use transaction strategy for speed.
    driver_shares_db_connection_with_specs = Capybara.current_driver == :rack_test

    if driver_shares_db_connection_with_specs
      DatabaseCleaner.strategy = :transaction
    else
      # Non-:rack_test driver is probably a driver for a JavaScript browser
      # with a Rack app under test that does *not* share a database
      # connection with the specs, so we must use truncation strategy.
      DatabaseCleaner.strategy = :truncation
    end
  end

  config.after(:example) do
    DatabaseCleaner.clean unless RSpec.current_example.metadata[:nodb]
  end
end
