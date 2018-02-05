ActiveAdmin.register User do
  actions :all
  permit_params :email, :password, :password_confirmation

  config.comments = false

  includes [:profile]

  scope -> { 'All' }, :all, :default => true

  batch_action :clone, priority: 2 do |ids|
    batch_action_collection.clone_all(id: ids)
    redirect_to collection_path, alert: 'Пользователь успешно клонирован.'
  end

  menu priority: 1, label: proc { I18n.t('active_admin.admin_users') }, id: 'user'

  controller do
    after_action :send_credentials, only: [:create]

    def find_resource
      scoped_collection.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      scoped_collection.find(params[:id])
    end

    def redirect_to_edit
      @user = find_resource
      redirect_to edit_admin_user_path(current_admin), Hash.new(flash) if current_admin?(@user)
    end

    alias_method :show, :redirect_to_edit

    private

    def send_credentials
      AdminUserNoticeJob.perform_later(@user.id, permitted_params[:user][:password])
    end

    def current_admin?(user)
      return false unless user
      current_admin.id == user.id
    end
  end

  collection_action :autocomplete do
    relation = User.includes(:profile)
    @users = if params[:q]
      relation
        .where('users.login LIKE ?', "#{params[:q]}%")
        .order(:login).limit(10)
    elsif params[:id]
      relation
        .where(id: params[:id]).limit(1)
    else
      relation
    end
  end

  filter :genres, as: :select2_tags_ajax,
         placeholder: 'Выберите жанр',
         context: 'genres',
         url: :autocomplete_admin_tags_path
  filter :email
  filter :time_zone, as: :select, collection: proc { time_zone_options_for_select }
  filter :created_at
  filter :updated_at
  filter :last_sign_in_at
  filter :is_clone
  filter :locked

  show do
    tabs do
      tab 'Описание' do
        attributes_table do
          row :role do |user|
            enum_status_tag(user, :role)
          end
          row :email
          row :safecrow_id
          row :time_zone
          # row :tag_list
          row :genre_list
          row(:purse) { |u| u.purse&.value }
          row :updated_at
          row :last_sign_in_at
          row :failed_attempts
          row :is_clone
        end
      end
    end

    active_admin_comments
  end

  index do
    selectable_column
    id_column
    column :login do |user|
      user&.login
    end
    column :name do |user|
      user&.full_name
    end
    column :email, as: :email
    column :role do |user|
      enum_status_tag(user, :role)
    end
    column :updated_at
    column :is_clone
    column :failed_attempts
    actions
  end

  form html: { multipart: true } do |f|
    tabs do
      tab 'Данные' do
        f.inputs do
          f.input :role, as: :select,
                  collection: model_enum_keys_for_select(User, :role),
                  include_blank: false
          f.input :time_zone, as: :select2,
                  collection: time_zone_options_for_select(f.object.time_zone.blank? ? 'UTC' : f.object.time_zone)
          f.input :email, as: :email
          f.input :safecrow_id
          # f.input :tag_list, as: :select2_tags_ajax,
          #         collection: f.object&.tags.pluck(:name),
          #         placeholder: 'Выберите тег',
          #         url: autocomplete_admin_tags_path
          f.input :genre_list, as: :select2_tags_ajax,
                  collection: f.object&.genres.pluck(:name),
                  placeholder: 'Выберите жанр',
                  context: 'genres',
                  url: autocomplete_admin_tags_path
          if f.object.new_record?
            f.input :password
            f.input :password_confirmation, required: true
          end
          f.input :is_clone
        end
      end
    end
    f.actions
  end
end
