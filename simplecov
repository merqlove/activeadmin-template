require "simplecov"
SimpleCov.start("rails") do
  add_filter("/bin/")
  add_filter("/lib/tasks/auto_annotate_models.rake")
  add_filter("/lib/tasks/coverage.rake")
  add_filter '/spec/'
  add_filter '/vendor/'

  add_group 'Controllers', 'app/controllers'
  add_group 'Models',      'app/models'
  add_group 'Helpers',     'app/helpers'
  add_group 'Mailers',     'app/mailers'
  add_group 'Views',       'app/views'
  add_group 'Jobs',        'app/jobs'
  add_group 'System',      'app/system'
  add_group 'Uploaders',   'app/uploaders'
end
SimpleCov.minimum_coverage(90)
SimpleCov.use_merging(false)
