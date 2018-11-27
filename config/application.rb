gsub_file "config/application.rb",
          "# config.time_zone = 'Central Time (US & Canada)'",
          'config.time_zone = "Moscow"'


data = {}

pg_hero =
    <<-RUBY
    if ENV['PGHERO'] == '1'
      require 'pghero'
      require 'pg_query'
    end
    RUBY

data[:pg_hero] = pg_hero if apply_pg_hero?

insert_into_file "config/application.rb", after: /^Bundler.require.*/ do
  <<-RUBY
  #{data[:pg_hero]}

  if defined?(Dotenv)
    Dotenv.overload unless Rails.env.production?
  end
  RUBY
end

mailkick =
  <<-RUBY

  # Cleanup routes
  initializer 'mailkick', after: 'add_routing_paths' do |app|
    app.routes_reloader.paths.delete_if{ |path| path.include?('mailkick') }
  end
  RUBY

sidekiq =
  <<-RUBY

  # Use sidekiq to process Active Jobs (e.g. ActionMailer's deliver_later)
  config.active_job.queue_adapter = :sidekiq
  RUBY

db =
  <<-RUBY

  config.active_record.schema_format = :sql
  RUBY

data[:mailkick] = mailkick if apply_mailkick?
data[:sidekiq] = sidekiq if apply_sidekiq?
data[:db] = db if apply_db?

insert_into_file "config/application.rb", after: /Rails::Application\n/ do
  <<-RUBY
    #{data[:mailkick]}
    #{data[:sidekiq]}
    #{data[:db]}

    config.autoload_paths += %W(\#{config.root}/app/services)
    config.autoload_paths += %W(\#{config.root}/app/jobs)
    config.autoload_paths += %W(\#{config.root}/app/pipelines)

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    config.time_zone = 'UTC'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    config.i18n.default_locale = :ru

    config.action_dispatch.default_headers.merge!({
                                                    'X-UA-Compatible' => 'IE=edge'
                                                  })
  RUBY
end
