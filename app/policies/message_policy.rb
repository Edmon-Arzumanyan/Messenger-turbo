class MessagePolicy < ApplicationPolicy
  def update?
    user.present? && user == record.user
  end

  def edit?
    update?
  end

  def destroy?
    update?
  end

  def reply?
    user.present?
  end
end
