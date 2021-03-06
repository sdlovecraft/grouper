class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?, :is_friend?

  def current_user
    @current_user ||= User.find(session[:user_id]) if logged_in?
  end
  
  def delete_notification(notifiable)
    @notification = Notification.find_by(notifiable: notifiable)
    @notification.destroy if @notification
  end

  def create_notification(creator, user, notifiable) 
    unless creator  == user
      @notification = Notification.create(
        user: user, 
        notifiable: notifiable, 
        creator: creator,
        user_checked: false)
    end
  end


  def logged_in?
    !!session[:user_id]
  end

  def require_user
    unless logged_in?
      redirect_to login_path
    end
  end
end

