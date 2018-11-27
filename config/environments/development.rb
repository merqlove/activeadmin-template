mailer_regex = /config\.action_mailer\.raise_delivery_errors = false\n/

comment_lines "config/environments/development.rb", mailer_regex
insert_into_file "config/environments/development.rb", after: mailer_regex do
  <<-RUBY
  #{'config.active_job.queue_adapter = :sidekiq' if apply_sidekiq?}

  # Ensure mailer works in development.
  config.action_mailer.delivery_method = :letter_opener_web
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = { host: "localhost:3000" }
  config.action_mailer.asset_host = "http://localhost:3000"
  RUBY
end

if apply_guard?
  insert_into_file "config/environments/development.rb", before: /^end/ do
    <<-RUBY

    # Automatically inject JavaScript needed for LiveReload.
    config.middleware.insert_after(ActionDispatch::Static, Rack::LiveReload)
    RUBY
  end
end

gsub_file "config/environments/development.rb",
          "join('tmp/caching-dev.txt')",
          'join("tmp", "caching-dev.txt")'
