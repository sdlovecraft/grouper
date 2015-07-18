class ApplicationController < ActionController::Base
  protect_from_forgery

  helper_method :current_user, :logged_in?

  def current_user
    @current_user ||= User.find(session[:user_id]) if logged_in?
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

