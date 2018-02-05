class AdminUserMailer < ApplicationMailer
  def notice(admin_user, password)
    @admin_user = admin_user
    @password = password
    mail(to: @admin_user.email)
  end
end
