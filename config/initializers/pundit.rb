module PunditHelper
  extend ActiveSupport::Concern

  included do
    include Pundit
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  end

  private

  def user_not_authorized
    api_error
    flash[:alert] = 'Access denied.'
    redirect_to (request.referrer || root_path)
  end

end

module PunditApiHelper
  extend ActiveSupport::Concern

  included do
    include Pundit
    rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
    rescue_from Pundit::AuthorizationNotPerformedError, with: :authorization_not_performed
    rescue_from Pundit::PolicyScopingNotPerformedError, with: :policy_scope_not_performed
  end

  private

  def user_not_authorized
    render json: { error: 'Bad credentials' }, status: 401
  end

  def authorization_not_performed
    render json: { error: 'Auth is not performed' }, status: 500
  end

  def policy_scope_not_performed
    render json: { error: 'Policy is not performed' }, status: 500
  end

end

