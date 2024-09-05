# frozen_string_literal: true

class MessagesController < ApplicationController
  before_action :set_chat
  before_action :set_message, only: %i[edit update destroy reply]

  # GET /messages/new
  def new
    @message = Message.new
  end

  def reply
    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            target: "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: @message.children.new }
          )
        ]
      end
    end
  end

  # GET /messages/1/edit
  def edit
    respond_to do |format|
      format.html do
        render :edit
      end

      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            target: "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: @message }
          )
        ]
      end
    end
  end

  # POST /messages or /messages.json
  def create
    @message = @chat.messages.build(message_params)
    @message.user = current_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to chats_url, notice: 'chat was successfully created.' }
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            target: "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: Message.new }
          )
        ]
        end
      end
    else
      respond_to do |format|
        format.html { redirect_to chats_url, notice: 'chat was successfully created.' }
        format.turbo_stream
      end
    end
  end

  # PATCH/PUT /messages/1 or /messages/1.json
  def update
    respond_to do |format|
      if @message.update(message_params)
        format.html { redirect_to message_url(@message), notice: 'Message was successfully updated.' }
        format.json { render :show, status: :ok, location: @message }
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            target: "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: Message.new }
          )
        ]
        end
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message.errors, status: :unprocessable_entity }
        format.turbo_stream
      end
    end
  end

  # DELETE /messages/1 or /messages/1.json
  def destroy
    if @message.destroy
      respond_to do |format|
        format.html { redirect_to messages_path, notice: 'Message was successfully destroyed.' }
        format.json { head :no_content }
        format.turbo_stream do
          render turbo_stream: [
          turbo_stream.replace(
            "message_form",
            target: "message_form",
            partial: 'messages/form',
            locals: { chat: @chat, message: Message.new }
          )
        ]
        end
      end
    else
      format.json { render json: @message.errors, status: :unprocessable_entity }
      format.turbo_stream
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_message
    @message = @chat.messages.find_by_id(params[:id])
  end

  def set_chat
    @chat = Chat.find_by_id(params[:chat_id])
    render :index, status: :not_found unless @chat
  end

  # Only allow a list of trusted parameters through.
  def message_params
    params.require(:message).permit(:parent_id, :body, files: [])
  end
end
