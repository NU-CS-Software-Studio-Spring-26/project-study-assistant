class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if session[:user_id]
  end

  def create
    user = User.find_by(email: params[:email].to_s.strip.downcase)
    if user&.authenticate(params[:password])
      session[:user_id] = user.id
      IcalSyncService.new(user).sync if user.ical_url.present?
      redirect_to assignments_path
    else
      flash.now[:alert] = "Invalid email or password."
      render :new, status: :unprocessable_entity
    end
  end

  def google_callback
    auth = request.env["omniauth.auth"]
    email = auth.info.email.to_s.downcase

    unless email.end_with?("@u.northwestern.edu") || email.end_with?("@northwestern.edu")
      redirect_to login_path, alert: "Please use your Northwestern email to sign in."
      return
    end

    user = User.from_google(auth)
    session[:user_id] = user.id

    if user.ical_url.blank?
      redirect_to edit_user_path(user), alert: "Please add your Canvas iCal URL to sync your assignments."
    else
      IcalSyncService.new(user).sync
      redirect_to assignments_path
    end
  rescue => e
    Rails.logger.error "Google OAuth error: #{e.message}"
    redirect_to login_path, alert: "Google sign-in failed. Please try again."
  end

  def auth_failure
    redirect_to login_path, alert: "Google sign-in was cancelled or failed."
  end

  def destroy
    reset_session
    redirect_to root_path
  end
end