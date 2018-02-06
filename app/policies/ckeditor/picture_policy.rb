class Ckeditor::PicturePolicy
  attr_reader :user, :picture

  def initialize(user, picture)
    @user = user
    @picture = picture
  end

  def index?
    user.admin?
  end

  def create?
    user.admin?
  end

  def destroy?
    picture.parent_id == user.id || user.admin?
  end
end
