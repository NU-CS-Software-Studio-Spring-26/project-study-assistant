class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Exception, with: :render_500 unless Rails.env.development?

  private

  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    redirect_to login_path, alert: "Please sign in to continue."
  end

  def render_500(exception = nil)
    Rails.logger.error exception&.message
    render file: Rails.root.join("app/views/errors/internal_server_error.html.erb"),
           status: :internal_server_error, layout: false
  end

  def render_not_found
    render file: Rails.root.join("app/views/errors/not_found.html.erb"),
           status: :not_found, layout: false
  end
end