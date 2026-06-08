class PasswordResetsController < ApplicationController
  def new
  end

  def create
    email = params[:email].to_s.strip.downcase
    user = User.find_by(email: email)
    if user && !user.google_user?
      user.generate_password_reset_token!
      PasswordResetMailer.reset_email(user).deliver_now
    end
    redirect_to new_password_reset_path,
                notice: "If an account exists for that email, a reset link has been sent."
  end

  def edit
    @user = User.find_by(reset_password_token: params[:token])
    if @user.nil? || @user.password_reset_expired?
      redirect_to new_password_reset_path,
                  alert: "That password reset link is invalid or has expired. Please request a new one."
      nil
    else
      @token = params[:token]
    end
  end

  def update
    @user = User.find_by(reset_password_token: params[:token])
    if @user.nil? || @user.password_reset_expired?
      redirect_to new_password_reset_path,
                  alert: "That password reset link is invalid or has expired. Please request a new one."
      return
    end

    if @user.update(password: params[:password], password_confirmation: params[:password_confirmation])
      @user.clear_password_reset!
      session[:user_id] = @user.id
      redirect_to dashboard_path, notice: "Password updated successfully. You are now signed in."
    else
      @token = params[:token]
      render :edit, status: :unprocessable_entity
    end
  end
end
