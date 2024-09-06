# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_chat
  before_action :set_message, only: %i[edit update destroy reply]

  def new
    @message = Message.new
    respond_with_form
  end

  def edit
    respond_with_form
  end

  def create
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to chats_path, notice: 'Message was successfully created.' }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  def update
    if @message.update(message_params.merge(is_edited: true))
      respond_to do |format|
        format.html { redirect_to chats_path, notice: 'Message was successfully updated.' }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  def destroy
    if @message.destroy
      respond_to do |format|
        format.html { redirect_to chats_path, notice: 'Message was successfully destroyed.' }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  def reply
    respond_with_form(@message.children.new)
  end

  private

  def respond_with_form(message = @message)
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: message }
          )
        ]
      end
    end
  end

  def replace_form_with_new_message
    render turbo_stream: [
      turbo_stream.replace(
        "message_form",
        partial: 'messages/form',
        locals: { chat: @chat, message: Message.new }
      )
    ]
  end

  def handle_message_error
    respond_to do |format|
      format.turbo_stream
    end
  end

  def set_message
    @message = @chat.messages.find_by_id(params[:id])
    return if @message

    redirect_to chats_path
  end

  def set_chat
    @chat = Chat.find_by_id(params[:chat_id])
    return if @chat

    redirect_to chats_path
  end

  def message_params
    params.require(:message).permit(:parent_id, :body, files: [])
  end
end
