class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if session[:user_id]
  end

  def create
    user = User.find_by(email: params[:email])
    if user
      session[:user_id] = user.id
      redirect_to assignments_path, notice: "Welcome back, #{user.name}!"
    else
      flash[:alert] = "No account found with that email."
      render :new
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out."
  end
end