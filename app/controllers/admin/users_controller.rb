class Admin::UsersController < ApplicationController
  include Resourceable

  def filter(results)
    if params[:last_seen_from].present?
      results = results.where('last_seen_at >= ?', params[:last_seen_from].to_date.beginning_of_day)
    end

    if params[:last_seen_to].present?
      results = results.where('last_seen_at <= ?', params[:last_seen_to].to_date.end_of_day)
    end

    results
  end

  def log_in_as_user
    sign_in(@resource, scope: :user)

    flash[:success] = "Logged in as #{@resource}"
    redirect_to root_path
  end

  ##############################################################################
  # resources
  ##############################################################################

  def resource_class
    User
  end

  def resource_class_for_search
    User
  end

  ##############################################################################
  # paths
  ##############################################################################

  def path_index
    admin_users_path
  end

  def path_show(external_resource = nil)
    admin_user_path(external_resource || resource)
  end

  def path_new
    new_admin_user_path
  end

  def path_create
    raise NotImplementedError
  end

  def path_edit
    edit_admin_user_path(resource)
  end

  def path_update
    raise NotImplementedError
  end

  def path_destroy
    raise NotImplementedError
  end

  private

  def resource_params
    params
      .require(:user)
      .permit(:admin,
              :first_name,
              :last_name,
              :phone,
              :email,
              :password,
              :image)
  end

  def set_resource
    @resource = User.find_by_id(params[:id] || params[:user_id])
    return if @resource

    redirect_to path_index, alert: t('alerts.not_found')
  end
end
