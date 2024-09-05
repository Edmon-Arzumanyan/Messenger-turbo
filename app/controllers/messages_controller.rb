# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_chat
  before_action :set_message, only: %i[edit update destroy reply]

  # GET /messages/new
  def new
    @message = Message.new
    respond_with_form
  end

  # GET /messages/1/edit
  def edit
    respond_with_form
  end

  # POST /messages or /messages.json
  def create
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to chats_url, notice: 'Message was successfully created.' }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    if @message.update(message_params)
      respond_to do |format|
        format.html { redirect_to message_url(@message), notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    if @message.destroy
      respond_to do |format|
        format.html { redirect_to messages_path, notice: 'Message was successfully destroyed.' }
        format.json { head :no_content }
        format.turbo_stream { replace_form_with_new_message }
      end
    else
      handle_message_error
    end
  end

  # Reply action
  def reply
    respond_with_form(@message.children.new)
  end

  private

  def respond_with_form(message = @message)
    respond_to do |format|
      format.html { render :edit }
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
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @message.errors, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  def set_message
    @message = @chat.messages.find_by_id(params[:id])
  end

  def set_chat
    @chat = Chat.find_by_id(params[:chat_id])
    render :index, status: :not_found unless @chat
  end

  def message_params
    params.require(:message).permit(:parent_id, :body, files: [])
  end
end
