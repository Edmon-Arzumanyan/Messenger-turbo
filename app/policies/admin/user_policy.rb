module Admin
  class UserPolicy < ApplicationPolicy
    def log_in_as_user?
      user&.admin?
    end
  end
end
