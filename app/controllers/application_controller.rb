require 'application_responder'

class ApplicationController < ActionController::Base
  self.responder = ApplicationResponder
  respond_to :html

  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :set_paper_trail_whodunnit
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :update_last_seen_at

  private

  def update_last_seen_at
    return unless user_signed_in?

    current_user.update(last_seen_at: Time.current)
  end

  def user_not_authorized
    redirect_back_or_to root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name phone image])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name phone image])
  end
end
