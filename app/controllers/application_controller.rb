class ApplicationController < ActionController::Base

  protect_from_forgery

  protected

  def admin?
    session[:password] == 'password' #ENV['DIGEST']
  end  

  def authorize
    unless admin?
      redirect_to posts_path
      false
    end
  end
  
end 
