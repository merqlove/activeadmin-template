apply 'config/application.rb'
apply 'config/boot.rb'
copy_file 'config/brakeman.yml'
template 'config/database.example.yml.tt'
template 'config/database.example.yml.tt', 'config/database.yml', :force => true
copy_file 'config/puma.rb', :force => true
copy_file 'config/secrets.yml', :force => true

copy_file 'config/sidekiq.yml' if apply_sidekiq?

after_bundle do
  create_initial_kaminari if apply_kaminari?
end

if apply_capistrano?
  template 'config/deploy.rb.tt'
  template 'config/deploy/production.rb.tt'
  template 'config/deploy/staging.rb.tt'
end

gsub_file 'config/routes.rb', /  # root 'welcome#index'/ do
  <<-RUBY
    mount LetterOpenerWeb::Engine, at: '/smtp' if Rails.env.development?

    get '/robots.txt', to: proc { |_| [                                                              
      200,
      { 'Content-Type' => 'text/plain' },
      [ "User-agent: *\\nDisallow: /" ]
    ]}

    get 'unauthorized' => 'web/welcome#index'

    scope module: :web do
      get 'welcome' => 'welcome#index'
    end

    root "web/welcome#index"
  RUBY
end

template 'config/initializers/generators.rb'
template 'config/initializers/errors.rb'

copy_file 'config/initializers/rails_settings_cached.rb' if apply_settings?
template 'config/initializers/pundit.rb' if apply_pundit?
template 'config/initializers/rollbar.rb.tt' if apply_rollbar?
copy_file 'config/initializers/profiler.rb' if apply_profiler?
copy_file 'config/initializers/rotate_log.rb'
copy_file 'config/initializers/secret_token.rb'
copy_file 'config/initializers/carrier_wave.rb' if apply_upload?
copy_file 'config/initializers/secure_headers.rb' if apply_protection?
copy_file 'config/initializers/version.rb'

after_bundle do
  copy_file 'config/initializers/middlewares.rb'
  copy_file 'config/initializers/non_digest_assets.rb'
  copy_file 'config/initializers/gc.rb'
  copy_file 'config/initializers/gaffe.rb' if apply_exceptions?
  copy_file 'config/initializers/acts_as_taggable_on.rb' if apply_tags?
  copy_file 'config/initializers/acts_as_follower.rb' if apply_followers?
end

if apply_redis?
  remove_file 'config/initializers/session_store.rb'
  template 'config/initializers/session_store.rb.tt'
end

if apply_sidekiq?
  template 'config/initializers/sidekiq.rb.tt'
  create_initial_whenever
end

template 'config/initializers/session_store.rb.tt' if apply_redis?

gsub_file 'config/initializers/filter_parameter_logging.rb', /\[:password\]/ do
  '%w[password secret session cookie csrf]'
end

apply 'config/environments/development.rb'
apply 'config/environments/production.rb'
apply 'config/environments/test.rb'
template 'config/environments/staging.rb.tt'

if apply_devise?
  after_bundle do
    insert_into_file 'config/initializers/devise.rb', after: /  # config\.secret_key.*/ do
      <<-RUBY
        config.secret_key = ENV.fetch('DEVISE_SECRET_KEY')
      RUBY
    end

    gsub_file 'config/initializers/devise.rb', /  config.case_insensitive_keys = \[:email\]/ do
      "  # config.case_insensitive_keys = [:email]
         config.case_insensitive_keys = [:email, :login]"
    end

    gsub_file 'config/initializers/devise.rb', /  config.strip_whitespace_keys = \[:email\]/ do
      "  # config.strip_whitespace_keys = [:email]
         config.strip_whitespace_keys = [:email, :login]"
    end
  end
end

after_bundle do
  template 'config/initializers/ckeditor.rb.tt' if apply_ckeditor?

  create_initial_settings if apply_settings?
  create_initial_pundit if apply_pundit?
  create_initial_mailkick if apply_mailkick?
end

aa_menu =
  <<-RUBY

    config.namespace :admin do |admin|
      admin.build_menu :utility_navigation do |menu|
        menu.add id: 'current_user',
                 priority: 30,
                 label: -> { display_name current_active_admin_user },
                 url:   -> { admin_account_path(current_active_admin_user) },
                 if:    :current_active_admin_user?
        menu.add id: 'current_user_edit',
                 label: -> { I18n.t('active_admin.account') },
                 parent: 'current_user',
                 priority: 10,
                 url:   -> { admin_account_path(current_active_admin_user) },
                 html_options: { class: 'left' }
        admin.add_logout_button_to_menu menu
      end
    end
  RUBY

aa_routes =
  <<-RUBY
    devise_aa_config = ActiveAdmin::Devise.config
    devise_aa_config[:singular] = :admin
    devise_aa_config[:skip] = [:registrations, :unlocks, :confirmations]

    devise_for :users, devise_aa_config

  RUBY

mounts = {}

if apply_sidekiq?
  mounts[:sidekiq] = <<-RUBY
      require 'sidekiq/web'
      mount Sidekiq::Web => '/jobs'
  RUBY
end

if apply_ckeditor?
  mounts[:ckeditor] = <<-RUBY
      mount Ckeditor::Engine => '/ckeditor'
  RUBY
end

if apply_pg_hero?
  mounts[:pghero] = <<-RUBY
      mount PgHero::Engine => '/pghero' if Rails.application.secrets.pghero
  RUBY
end

aa_routes_new =
  <<-RUBY
  namespace :admin do
    authenticate :admin, ->(u) { u.admin? } do
      #{mounts[:ckeditor]}
      #{mounts[:pghero]}
      #{mounts[:sidekiq]}
    end
  end
  RUBY

aa_settings =
  <<-RUBY

    ActiveadminSettingsCached.configure do |config|
      config.model_name = 'Setting'
    end
  RUBY

if apply_aa?
  after_bundle do
    create_initial_aa

    copy_file 'config/initializers/formtastic.rb'

    insert_into_file 'config/initializers/active_admin.rb', before: /^ActiveAdmin.setup.*/ do
      <<-RUBY
      require 'active_admin/inputs/filters/select2_multiple_ajax_input'
      require 'formtastic/inputs/select2_ajax_input'
      require 'formtastic/inputs/select2_multiple_ajax_input'
      require 'formtastic/inputs/color_picker_input'

      RUBY
    end

    if apply_tags?
      insert_into_file 'config/initializers/active_admin.rb', before: /^ActiveAdmin.setup.*/ do
        <<-RUBY
        require 'active_admin/inputs/filters/select2_tags_ajax_input'
        require 'formtastic/inputs/select2_tags_ajax_input'

        RUBY
      end
    end

    if apply_settings?
      insert_into_file 'config/initializers/active_admin.rb', before: /^ActiveAdmin.setup.*/ do
        aa_settings
      end
    end

    insert_into_file 'config/initializers/active_admin.rb', after: /^ {2}# config.logout_link_method.*\n/ do
      <<-RUBY
        config.logout_link_method = :delete
      RUBY
    end
    insert_into_file 'config/initializers/active_admin.rb', after: /^ {2}# config.comments_menu.*\n/ do
      <<-RUBY

        config.comments_menu = :false

      RUBY
    end
    insert_into_file 'config/initializers/active_admin.rb', before: /^end/ do
      aa_menu
    end
    insert_into_file 'config/initializers/active_admin.rb', after: /^ {2}# To disable\/customize.*\n/ do
      <<-RUBY
        config.download_links = %i[csv json]
      RUBY
    end

    insert_into_file 'config/routes.rb', before: /^ {2}ActiveAdmin.routes.*/ do
      aa_routes
    end

    insert_into_file 'config/routes.rb', after: /^ {2}ActiveAdmin.routes\(self\).*\n/ do
      aa_routes_new
    end
  end
end
