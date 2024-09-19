class Admin::MessagesController < ApplicationController
  include Resourceable

  def filter(results)
    results = results.search(params[:query]) if params[:query].present?
    results = results.where(user_id: params[:user]) if params[:user].present?
    results = results.where(chat_id: params[:chat]) if params[:chat].present?

    results
  end

  ##############################################################################
  # resources
  ##############################################################################

  def resource_class
    Message
  end

  def resource_class_for_search
    Message
  end

  ##############################################################################
  # paths
  ##############################################################################

  def path_index
    admin_messages_path
  end

  def path_show(external_resource = nil)
    admin_message_path(external_resource || resource)
  end

  def path_new
    raise NotImplementedError
  end

  def path_create
    raise NotImplementedError
  end

  def path_edit
    admin_edit_message_path(resource)
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
      .require(:message)
      .permit(:user_id,
              :chat_id,
              :parent_id,
              :admin,
              :body,
              :status,
              :is_edited,
              files: [])
  end

  def set_resource
    @resource = Message.find_by_id(params[:id])
    return if @resource

    redirect_to path_index, alert: t('alerts.not_found')
  end
end
