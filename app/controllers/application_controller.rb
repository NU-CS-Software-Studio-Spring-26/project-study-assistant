class ApplicationController < ActionController::Base
  include Pagy::Method
  allow_browser versions: :modern
  stale_when_importmap_changes
  helper_method :current_user
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
  rescue_from Exception, with: :render_500 unless Rails.env.development?
  before_action :require_login
  private
  def current_user
    @current_user ||= User.find_by(id: session[:user_id])
  end
  def require_login
    return if current_user
    return if controller_name == "sessions"
    return if controller_name == "pages"
    return if controller_name == "users" && action_name.in?(%w[new create])
    return if controller_name == "password_resets"
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
