class AdminUserNoticeJob < ApplicationJob
  def perform(id, password)
    user = User.find(id)
    AdminUserMailer.notice(user, password).deliver_now
  end
end
