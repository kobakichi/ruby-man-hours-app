class ApplicationController < ActionController::Base
  include Pundit::Authorization
  before_action :authenticate_user!
  before_action :set_current_organization

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  helper_method :current_organization, :manager_or_admin?

  private

  def set_current_organization
    return unless current_user
    @current_organization = current_user.organizations.first || Organization.first
  end

  def current_organization
    @current_organization
  end

  def manager_or_admin?(org = current_organization)
    return false unless current_user && org
    role = current_user.memberships.find_by(organization_id: org.id)&.role
    %w[manager admin].include?(role)
  end

  def user_not_authorized
    redirect_to(request.referer || root_path, alert: '許可されていません。')
  end
end
