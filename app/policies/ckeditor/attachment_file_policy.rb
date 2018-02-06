class Ckeditor::AttachmentFilePolicy
  attr_reader :user, :attachment

  def initialize(user, attachment)
    @user = user
    @attachment = attachment
  end

  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def destroy?
    attachment.parent_id == user.id || user.admin?
  end
end
