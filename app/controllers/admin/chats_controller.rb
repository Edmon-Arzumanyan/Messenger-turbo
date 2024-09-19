class Admin::ChatsController < ApplicationController
  include Resourceable

  def filter(results)
    results = results.search(params[:query]) if params[:query].present?
    results = results.where(user_1_id: params[:user_1]) if params[:user_1].present?
    results = results.where(user_2_id: params[:user_2]) if params[:user_2].present?

    results
  end

  ##############################################################################
  # resources
  ##############################################################################

  def resource_class
    Chat
  end

  def resource_class_for_search
    Chat
  end

  ##############################################################################
  # paths
  ##############################################################################

  def path_index
    admin_chats_path
  end

  def path_show(external_resource = nil)
    admin_chat_path(external_resource || resource)
  end

  def path_new
    raise NotImplementedError
  end

  def path_create
    raise NotImplementedError
  end

  def path_edit
    admin_edit_chat_path(resource)
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
      .require(:chat)
      .permit(:user_1_id,
              :user_2_id,
              :admin,
              :last_discarded_at)
  end

  def set_resource
    @resource = Chat.find_by_id(params[:id])
    return if @resource

    redirect_to path_index, alert: t('alerts.not_found')
  end
end
