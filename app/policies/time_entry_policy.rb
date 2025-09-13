class TimeEntryPolicy < ApplicationPolicy
  def index?; true; end
  def show?; owner? || manager_or_admin?(record.organization); end
  def create?
    return user.present? if record.is_a?(Class)
    owner? || manager_or_admin?(record.organization)
  end
  def update?; owner? || manager_or_admin?(record.organization); end
  def destroy?; manager_or_admin?(record.organization); end

  class Scope < Scope
    def resolve
      org_ids = user.organizations.select(:id)
      # 管理者/マネージャーは所属組織内を全件、メンバーは自分の工数のみ
      if user.memberships.where(organization_id: org_ids, role: %i[manager admin]).exists?
        scope.where(organization_id: org_ids)
      else
        scope.where(organization_id: org_ids, user_id: user.id)
      end
    end
  end

  private
  def owner?
    record.respond_to?(:user_id) && record.user_id == user.id
  end
  def manager_or_admin?(org)
    return false unless org
    role = user.memberships.find_by(organization_id: org.id)&.role
    %w[manager admin].include?(role)
  end
end
