@after_bundle_callbacks = []

def after_bundlex(&block)
  @after_bundle_callbacks << block
end

def run_after_bundle(cmd)
  after_bundlex do
    puts cmd
    yield
  end
end

def create_initial_devise
  run_after_bundle 'bundle exec rails generate devise:install' do
    puts 'bin/rails generate devise:install'
    yield
  end
end

create_initial_devise do
  puts 'OTHER'
end

def bundlep
  @after_bundle_callbacks.each(&:call)
end
