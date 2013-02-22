class SessionsController < ApplicationController

  def new
  end

  def create
    session[:password] = params[:password]
    redirect_to posts_path
  end
  
  def destroy
    reset_session
    redirect_to :action => 'new'
  end

end
