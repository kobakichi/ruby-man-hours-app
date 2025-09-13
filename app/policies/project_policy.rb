class ProjectPolicy < ApplicationPolicy
  def index?; true; end
  def show?; member?(record.organization); end
  def create?; manager_or_admin?(record.organization); end
  def update?; manager_or_admin?(record.organization); end
  def destroy?; manager_or_admin?(record.organization); end

  class Scope < Scope
    def resolve
      org_ids = user.organizations.select(:id)
      scope.where(organization_id: org_ids)
    end
  end

  private
  def member?(org)
    user.memberships.exists?(organization_id: org.id)
  end
  def manager_or_admin?(org)
    role = user.memberships.find_by(organization_id: org.id)&.role
    %w[manager admin].include?(role)
  end
end
