apply "app/assets/javascripts/application.js.rb"
copy_file "app/assets/stylesheets/application.scss"
remove_file "app/assets/stylesheets/application.css"

validations_user =
  <<-RUBY
  validates_presence_of   :email
  validates_uniqueness_of :email, scope: :login, allow_blank: true, if: -> { email_changed? || login_changed? }
  validates_format_of     :email, with: Devise.email_regexp, allow_blank: true

  validates_format_of     :login, with: /\A[a-z0-9_\-]+\z/i, allow_blank: true, if: :login_changed?

  RUBY

enum_user =
  <<-RUBY
  enum role: {
    user: 0,
    manager: 1,
    admin: 2
  }

  after_initialize :set_default_role, if: :new_record?

  def role
    return 'user' if read_attribute(:role).blank?
    read_attribute(:role)
  end

  private

  def set_default_role
    self.role = :user if read_attribute(:role).blank?
  end

  RUBY

clone_user =
  <<-RUBY
  include CloneAll

  def cloning
    user = deep_clone do |orig, kopy|
      if kopy.is_a?(User)
        kopy.is_clone = true
        kopy.login = nil
        kopy.email = "\#{UUID.generate(:compact)[0..6]}-\#{orig.email}"
        kopy.password = "cloned-user"
        kopy.tag_list = orig.tag_list
        kopy.genre_list = orig.genre_list
      end
      if kopy.respond_to?(:copy_data_url=)
        kopy.copy_data_url = orig if kopy.data_file_name
      end
    end
    user.save!
  end

  RUBY

fid_user =
  <<-RUBY
  extend FriendlyId

  friendly_id do |config|
    config.base = :login_candidates
    config.defaults[:slug_column] = :login
    config.use :slugged
    config.use Module.new do
      def normalize_friendly_id(text)
        Russian.translit(text).parameterize
      end
    end
  end

  def login_candidates
    login
  end

  def should_generate_new_friendly_id?
    login.blank?
  end

  RUBY

if apply_spree?
  after_bundle do
    create_initial_spree
  end
end

if apply_devise? && !apply_spree?
  after_bundle do
    create_initial_devise

    insert_into_file 'app/models/user.rb', after: /^class User.*\n/ do
      validations_user
    end

    insert_into_file 'app/models/user.rb', after: /^class User.*\n/ do
      enum_user
    end

    if apply_fid?
      insert_into_file 'app/models/user.rb', after: /^class User.*\n/ do
        fid_user
      end
    end

    if apply_clone?
      insert_into_file 'app/models/user.rb', after: /^class User.*\n/ do
        clone_user
      end
    end
  end
end

aa_controller =
  <<-RUBY
    rescue_from ::AdminAccessDeniedError do |exception|
      active_admin_access_denied(exception)
    end

    def active_admin_access_denied(exception)
      sign_out :admin
      redirect_to new_admin_session_path, alert: exception.message
    end

    def authenticate_admin_user!
      fail ::AdminAccessDeniedError.new(t('active_admin.access_denied.message')) unless current_admin.try(:admin?)
    end
  RUBY

if apply_aa?
  after_bundle do
    copy_file "app/jobs/admin_user_notice_job.rb"
    copy_file "app/mailers/admin_user_mailer.rb"

    insert_into_file 'app/controllers/application_controller.rb', before: /^end/ do
      aa_controller
    end
  end
end

base_controller =
  <<-RUBY

    private

    def raise_not_found
      fail ::ActionController::RoutingError, "No route matches \#{params[:unmatched_route]}"
    end
  RUBY

api_base_controller =
  <<-RUBY
    def respond_with_json_error(message, status = 500)
      render json: { status: 'ERROR', messages: message }, status: status
    end
  RUBY

after_bundle do
  insert_into_file 'app/controllers/application_controller.rb', before: /^end/ do
    base_controller
  end

  if apply_api?
    insert_into_file 'app/controllers/application_controller.rb', before: /^end/ do
      api_base_controller
    end
  end

  if apply_aa? && apply_pundit?
    copy_file "app/policies/active_admin/comment_policy.rb"
    copy_file "app/policies/active_admin/page_policy.rb"
  end

  if apply_ckeditor? && apply_pundit?
    copy_file "app/policies/ckeditor/attachment_file_policy.rb"
    copy_file "app/policies/ckeditor/picture_policy.rb"
  end

  copy_file "app/services/application_service.rb"
  copy_file "app/pipelines/welcome_index_pipeline.rb"
end

copy_file "app/models/concerns/clone_all.rb" if apply_clone?
copy_file "app/models/concerns/friendly_concern.rb" if apply_fid?
copy_file "app/models/concerns/tag_list_concern.rb" if apply_tags?
copy_file "app/models/concerns/attachment_check.rb" if apply_trees?

if apply_upload?
  copy_file "app/uploaders/concerns/store_image_dimensions.rb"
  copy_file "app/uploaders/base_uploader.rb"
  copy_file "app/uploaders/base_audio_uploader.rb"
  copy_file "app/uploaders/base_image_uploader.rb"

  copy_file "app/models/attachment.rb"

  if apply_ckeditor?
    copy_file "app/uploaders/ckeditor_attachment_file_uploader.rb"
    copy_file "app/uploaders/ckeditor_picture_uploader.rb"

    copy_file "app/models/ckeditor/attachment_file.rb"
    copy_file "app/models/ckeditor/picture.rb"
    copy_file "app/models/concerns/ckeditor_assets.rb"
    copy_file "app/models/concerns/dynamic_data_url.rb"
  end
end

if apply_exceptions?
  copy_file "app/controllers/web/errors_controller.rb"
  copy_file "app/views/web/errors/bad_request.html.haml"
  copy_file "app/views/web/errors/forbidden.html.haml"
  copy_file "app/views/web/errors/internal_server_error.html.haml"
  copy_file "app/views/web/errors/method_not_allowed.html.haml"
  copy_file "app/views/web/errors/not_acceptable.html.haml"
  copy_file "app/views/web/errors/not_found.html.haml"
  copy_file "app/views/web/errors/not_implemented.html.haml"
  copy_file "app/views/web/errors/unauthorized.html.haml"
  copy_file "app/views/web/errors/unprocessable_entity.html.haml"
end

template "app/controllers/web/application_controller.rb.tt"
copy_file "app/controllers/web/welcome_controller.rb"

if apply_aa?
  after_bundle do
    copy_file "app/admin/account.rb"
    copy_file "app/admin/user.rb.txt"
  end

  if apply_pundit?
    after_bundle do
      copy_file "app/admin/account.rb"
    end
  end
end

copy_file "app/helpers/javascript_helper.rb"
copy_file "app/helpers/layout_helper.rb"
copy_file "app/helpers/retina_image_helper.rb"
copy_file "app/views/layouts/application.html.erb", :force => true
template "app/views/layouts/base.html.erb.tt"
copy_file "app/views/shared/_flash.html.erb"
copy_file "app/views/web/welcome/index.html.erb"
