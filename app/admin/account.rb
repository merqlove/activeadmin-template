ActiveAdmin.register User, as: 'Account' do
  actions :edit, :update, :clear_cache

  config.breadcrumb = proc { [] }

  permit_params :email, :password, :password_confirmation

  menu false

  collection_action :clear_cache, method: :get do
    begin
      Rails.cache.clear
      flash[:success] = t('active_admin.cache_clear_success'.freeze)
      redirect_back(fallback_location: admin_root_url, flash: Hash.new(flash))
    rescue => _
      flash[:error] = t('active_admin.cache_clear_error'.freeze)
      redirect_back(fallback_location: admin_root_url, flash: Hash.new(flash))
    end
  end

  controller do
    def redirect_to_edit
      redirect_to edit_admin_account_path(current_admin), Hash.new(flash)
    end

    def find_resource
      scoped_collection.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound
      scoped_collection.find(params[:id])
    end

    def update
      @user = find_resource
      if permitted_params[:user][:password].blank?
        @user.update_without_password(permitted_params[:user])
      else
        @user.update_attributes(permitted_params[:user])
      end
      if @user.errors.blank?
        redirect_to_edit
      else
        render :edit
      end
    end

    alias_method :index, :redirect_to_edit
    alias_method :show,  :redirect_to_edit
  end

  form do |f|
    f.inputs do
      f.input :email
      f.input :password, required: false
      f.input :password_confirmation, required: false
    end

    f.actions
  end
end
