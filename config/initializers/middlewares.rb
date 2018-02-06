# frozen_string_literal: true

Rails.application.config.middleware.insert_before 0, Rack::Attack
#
# if Rails.env.production?
#   Rails.application.config.middleware.insert_before Rack::Runtime, Rack::Timeout
#   Rack::Timeout.timeout = 10 # seconds
# end

Rails.application.config.middleware.insert_before ActionDispatch::Flash, ::Rack::Protection

Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    # origins '*'

    origins [
      %r{http[s]?://(localhost|127.0.0.1|0.0.0.0):300[05].*}
    ]

    resource '*',
             headers: :any,
             methods: %i[get post patch delete put options head],
             credentials: true,
             # :max_age => 0,
             expose: %w[access-token expiry token-type uid client Etag Server X-Content-Type-Options
                        X-Frame-Options X-Request-Id X-Runtime X-CSRF-Token X-CSRF-TOKEN X-XSRF-Token
                        if-modified-since
                        X-Xss-Protection Date Access-Control-Request-Method Access-Control-Allow-Origin
                        Connection Content-Length].join(',')
  end
end
