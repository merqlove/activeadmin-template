RAILS_REQUIREMENT = '~> 5.1.0'.freeze

def apply_template!
  assert_minimum_rails_version
  assert_valid_options
  assert_postgresql
  add_template_repository_to_source_path

  template 'Gemfile.tt', :force => true

  if apply_capistrano?
    template 'DEPLOYMENT.md.tt'
    template 'PROVISIONING.md.tt'
  end

  template 'README.md.tt', :force => true
  remove_file 'README.rdoc'

  template 'example.env.tt'
  template 'example.env.tt', '.env'
  copy_file 'gitignore', '.gitignore', :force => true
  copy_file 'overcommit.yml', '.overcommit.yml'
  template 'ruby-version.tt', '.ruby-version'
  copy_file 'simplecov', '.simplecov'

  copy_file 'Capfile' if apply_capistrano?
  copy_file 'VERSION'
  copy_file 'Guardfile' if apply_guard?
  copy_file 'Procfile'

  apply 'app/template.rb'
  apply 'bin/template.rb'
  apply 'circleci/template.rb'
  apply 'config/template.rb'
  apply 'doc/template.rb'
  apply 'db/template.rb'
  apply 'lib/template.rb'
  apply 'test/template.rb' if apply_minitest?
  apply 'spec/template.rb' unless apply_minitest?

  apply 'variants/bootstrap/template.rb' if apply_bootstrap?

  git :init unless preexisting_git_repo?
  empty_directory '.git/safe'

  run_with_clean_bundler_env 'bin/setup'
  create_initial_migration
  generate_spring_binstubs

  binstubs = %w[
    annotate brakeman bundler bundler-audit rubocop puma
  ]
  binstubs.push('guard') if apply_guard?
  binstubs.push('sidekiq') if apply_sidekiq?
  binstubs.push('capistrano') if apply_capistrano?
  run_with_clean_bundler_env "bundle binstubs #{binstubs.join(' ')} --force"

  template 'rubocop.yml.tt', '.rubocop.yml'
  run_rubocop_autocorrections

  unless any_local_git_commits?
    git :add => '-A .'
    git :commit => "-n -m 'Set up project'"
    git :checkout => '-b development' if apply_capistrano?
    if git_repo_specified?
      git :remote => "add origin #{git_repo_url.shellescape}"
      git :push => '-u origin --all'
    end
  end
end

require 'fileutils'
require 'shellwords'

# Add this template directory to source_paths so that Thor actions like
# copy_file and template resolve against our source files. If this file was
# invoked remotely via HTTP, that means the files are not present locally.
# In that case, use `git clone` to download them to a local temporary dir.
def add_template_repository_to_source_path
  if __FILE__ =~ %r{\Ahttps?://}
    require 'tmpdir'
    source_paths.unshift(tempdir = Dir.mktmpdir('rails-template-'))
    at_exit { FileUtils.remove_entry(tempdir) }
    git :clone => [
      '--quiet',
      'https://github.com/merqlove/rails-template.git',
      tempdir
    ].map(&:shellescape).join(' ')

    if (branch = __FILE__[%r{rails-template/(.+)/template.rb}, 1])
      Dir.chdir(tempdir) { git :checkout => branch }
    end
  else
    source_paths.unshift(File.dirname(__FILE__))
  end
end

def assert_minimum_rails_version
  requirement = Gem::Requirement.new(RAILS_REQUIREMENT)
  rails_version = Gem::Version.new(Rails::VERSION::STRING)
  return if requirement.satisfied_by?(rails_version)

  prompt = "This template requires Rails #{RAILS_REQUIREMENT}. "\
           "You are using #{rails_version}. Continue anyway?"
  exit 1 if no?(prompt)
end

# Bail out if user has passed in contradictory generator options.
def assert_valid_options
  valid_options = {
    :skip_gemfile => false,
    :skip_bundle => false,
    :skip_git => false,
    :skip_test_unit => false,
    :edge => false
  }
  valid_options.each do |key, expected|
    next unless options.key?(key)
    actual = options[key]
    unless actual == expected
      fail Rails::Generators::Error, "Unsupported option: #{key}=#{actual}"
    end
  end
end

def assert_postgresql
  return if IO.read('Gemfile') =~ /^\s*gem ['"]pg['"]/
  fail Rails::Generators::Error,
       'This template requires PostgreSQL, '\
       'but the pg gem isn’t present in your Gemfile.'
end

# Mimic the convention used by capistrano-mb in order to generate
# accurate deployment documentation.
def capistrano_app_name
  app_name.gsub(/[^a-zA-Z0-9_]/, '_')
end

def git_repo_url
  @git_repo_url ||=
    ask_with_default('What is the git remote URL for this project?', :blue, 'skip')
end

def production_hostname
  @production_hostname ||=
    ask_with_default('Production hostname?', :blue, 'example.com')
end

def staging_hostname
  @staging_hostname ||=
    ask_with_default('Staging hostname?', :blue, 'staging.example.com')
end

def gemfile_requirement(name)
  @original_gemfile ||= IO.read('Gemfile')
  req = @original_gemfile[/gem\s+['"]#{name}['"]\s*(,[><~= \t\d\.\w'"]*)?.*$/, 1]
  req && req.gsub("'", %(")).strip.sub(/^,\s*"/, ', "')
end

def ask_with_default(question, color, default)
  return default unless $stdin.tty?
  question = (question.split('?') << " [#{default}]?").join
  answer = ask(question, color)
  answer.to_s.strip.empty? ? default : answer
end

def git_repo_specified?
  git_repo_url != 'skip' && !git_repo_url.strip.empty?
end

def preexisting_git_repo?
  @preexisting_git_repo ||= (File.exist?('.git') || :nope)
  @preexisting_git_repo == true
end

def any_local_git_commits?
  system('git log &> /dev/null')
end

def apply_bootstrap?
  apply_way('apply_bootstrap','Use Bootstrap gems, layouts, views, etc.?')
end

def apply_sidekiq?
  apply_way('apply_sidekiq','Use Sidekiq?', 'yes')
end

def apply_exceptions?
  apply_way('apply_exceptions','Use Exceptions?', 'yes')
end

def apply_be?
  apply_way('apply_be','Use BetterErrors?')
end

def apply_pg_hero?
  apply_way('apply_pg_hero','Use PgHero?')
end

def apply_db?
  apply_way('apply_db','Use Db?', 'yes')
end

def apply_minitest?
  apply_way('apply_minitest','Use MiniTest (RSpec is default)?')
end

def apply_crypto?
  apply_way('apply_crypto','Use custom Crypto libraries?')
end

def apply_guard?
  apply_way('pply_guard','Use Guard?')
end

def apply_ckeditor?
  apply_way('apply_ckeditor','Use ckeditor?', 'yes')
end

def apply_protection?
  apply_way('apply_protection','Use Rack protection?', 'yes')
end

def apply_turbolinks?
  apply_way('apply_turbolinks','Use Turbolinks?', 'yes')
end

def apply_aa?
  apply_way('apply_aa','Use ActiveAdmin?', 'yes')
end

def apply_aasm?
  apply_way('apply_aasm','Use State Machines?', 'yes')
end

def apply_draper?
  apply_way('apply_draper','Use Draper?', 'yes')
end

def apply_dry?
  apply_way('apply_dry','Use DryRb?', 'yes')
end

def apply_clone?
  apply_way('apply_clone','Use Db Object cloning?', 'yes')
end

def apply_templates?
  apply_way('apply_templates','Use custom Templates engine?', 'yes')
end

def apply_upload?
  apply_way('apply_upload','Use Uploads?', 'yes')
end

def apply_fid?
  apply_way('apply_fid','Use FriendlyId?', 'yes')
end

def apply_settings?
  apply_way('apply_settings','Use RailsSettingsCached?', 'yes')
end

def apply_profiler?
  apply_way('apply_profiler','Use Profiler?')
end

def apply_api?
  apply_way('apply_api','Use API?')
end

def apply_trees?
  apply_way('apply_trees','Use Trees?', 'yes')
end

def apply_followers?
  apply_way('apply_followers','Use Followers?')
end

def apply_tags?
  apply_way('apply_tags','Use Tags?')
end

def apply_lograge?
  apply_way('apply_lograge','Use Lograge?', 'yes')
end

def apply_devise?
  apply_way('apply_devise','Use Devise?', 'yes')
end

def apply_pundit?
  apply_way('apply_pundit','Use Pundit?', 'yes')
end

def apply_rollbar?
  apply_way('apply_rollbar','Use Rollbar?', 'yes')
end

def apply_kaminari?
  apply_way('apply_kaminari','Use Pagination?', 'yes')
end

def apply_mailkick?
  apply_way('apply_mailkick','Use Mailkick?')
end

def apply_capistrano?
  apply_way('apply_capistrano','Use Capistrano for deployment?', 'yes')
end

def apply_redis?
  apply_way('apply_redis','Use Redis for cache & session?', 'yes')
end

def apply_way(_var, _text, default = 'no')
  return instance_variable_get(:"@#{_var}") if instance_variable_defined?(:"@#{_var}")
  instance_variable_set(:"@#{_var}", ask_with_default(_text, :blue, default) \
    =~ /^y(es)?/i)
end

def run_with_clean_bundler_env(cmd)
  return run(cmd) unless defined?(Bundler)
  Bundler.with_clean_env { run(cmd) }
end

def run_rubocop_autocorrections
  run_with_clean_bundler_env 'bin/rubocop -a --fail-level A > /dev/null'
end

def create_initial_migration
  return if Dir['db/migrate/**/*.rb'].any?
  run_with_clean_bundler_env 'bin/rails generate migration initial_migration'
  run_with_clean_bundler_env 'bin/rake db:migrate'
end

def run_after_bundle(cmd)
  after_bundle do
    run_with_clean_bundler_env cmd
    yield
  end
end

def create_initial_whenever
  run_after_bundle 'bin/bundle exec wheneverize .' do
    yield
  end
end

def create_initial_aa
  run_after_bundle 'bin/rails generate active_admin:install' do
    yield
  end
end

def create_initial_devise
  run_after_bundle 'bin/rails generate devise:install' do
    run_with_clean_bundler_env 'bin/rails generate devise:install'
    yield
  end
end

def create_initial_pundit
  run_after_bundle 'bin/rails generate pundit:install' do
    yield
  end
end

def create_initial_rspec
  run_after_bundle 'bin/rails generate rspec:install' do
    yield
  end
end

def create_initial_kaminari
  run_after_bundle 'bin/rails generate kaminari:config' do
    yield
  end
end

def create_initial_settings
  run_after_bundle 'bin/rails generate settings:install' do
    yield
  end
end

def create_initial_mailkick
  run_after_bundle 'bin/rails generate mailkick:install' do
    yield
  end
end

def create_initial_formtastic
  run_after_bundle 'bin/rails generate formtastic:install' do
    yield
  end
end

def create_initial_rollbar
  run_after_bundle 'bin/rails generate rollbar:rollbar' do
    yield
  end
end

apply_template!
