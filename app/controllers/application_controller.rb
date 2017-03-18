class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  def admin_required
    unless current_member.the_admin?
      redirect_to "/", notice: "Access denied"
      return
    end
  end
end
