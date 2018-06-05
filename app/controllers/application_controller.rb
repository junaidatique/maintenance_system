class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  layout :layout_by_resource
  before_action :authenticate_user!
  after_action :user_activity
  

  def after_sign_in_path_for(user)
    if user.admin?
      aircrafts_path    
    elsif user.log_asst?
      tools_path    
    elsif user.logistics?
      parts_path
    else
      flying_logs_path
    end
  	
  end

  private

  def user_activity
    current_user.try :touch
  end

  def layout_by_resource
    if devise_controller?
      'devise'
    else
      'application'
    end
  end
end
