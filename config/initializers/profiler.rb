if Rails.application.secrets.profiler

  require 'flamegraph'
  require 'rack-mini-profiler'

  # Rack::MiniProfiler.config.position = 'right'
  # Rack::MiniProfiler.config.start_hidden = true
  # Rack::MiniProfiler.config.auto_inject  = false
  Rack::MiniProfiler.config.skip_paths  = %w(/uploads)
  # Rack::MiniProfiler.config.storage = Rack::MiniProfiler::MemoryStore

  Rack::MiniProfiler.config.storage_options = { host: ENV['REDIS_HOST'],
                                                port: ENV['REDIS_PORT'] }
  Rack::MiniProfiler.config.storage = Rack::MiniProfiler::RedisStore
  Rack::MiniProfiler.config.disable_caching = false

  Rack::MiniProfilerRails.initialize!(Rails.application)
end
