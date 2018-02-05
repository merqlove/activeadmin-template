comment_lines "config/environments/production.rb",
              /config\.assets\.js_compressor = :uglifier/

insert_into_file "config/environments/production.rb",
                 :after => /# config\.assets\.css_compressor = :sass\n/ do
  <<-RUBY

  # Disable minification since it adds a *huge* amount of time to precompile.
  # Anyway, gzip alone gets us about 70% of the benefits of minify+gzip.
  config.assets.js_compressor = false
  config.assets.css_compressor = false

  config.lograge.enabled = true
  config.force_ssl = Rails.application.secrets.force_ssl
  RUBY
end

uncomment_lines "config/environments/production.rb",
                /config\.action_dispatch\.x_sendfile_header = 'X-Accel-Redirect' # for NGINX/i

insert_into_file "config/environments/production.rb",
                 :after => /# config\.action_mailer\.raise_deliv.*\n/ do
  <<-RUBY

  config.action_mailer.delivery_method = :smtp
  config.action_mailer.smtp_settings = {
    address:              Rails.application.secrets.smtp_host,
    port:                 Rails.application.secrets.smtp_port || 25,
    domain:               ENV['#{app_name.upcase}_DOMAIN'],
    user_name:            Rails.application.secrets.smtp_user_name,
    password:             Rails.application.secrets.secret_smtp_password,
    authentication:       ENV['SMTP_AUTH_TYPE'] || 'plain',
    enable_starttls_auto: (ENV['SMTP_STARTTLS'] ? true : false)
  }
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.default_url_options = {
    :host => "#{production_hostname}",
    :protocol => "https"
  }
  config.action_mailer.asset_host = "https://#{production_hostname}"
  RUBY
end
