# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: %i[show edit update destroy]

  def index
    @chats = current_user.chats
  end

  def new
    @chat = current_user.initiated_chats.new
  end

  def show
    @message = current_user.messages.new
    @messages = @chat.messages.order(created_at: :asc)

    @messages.unread.where.not(user_id: current_user.id).find_each do |message|
      message.update(status: 'read')
    end

    respond_to do |format|
      format.html do
        render :show
      end
      
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            @chat,
            target: @chat,
            partial: 'chats/chat',
            locals: { chat: @chat, user: current_user }
          ),
          turbo_stream.update(
            "#{current_user.id}_show",
            partial: 'chats/show',
            locals: { chat: @chat, user: current_user }
          )
        ]
      end
    end
  end

  def create
    @chat = current_user.initiated_chats.build(chat_params)

    if @chat.save
      respond_to do |format|
        format.html { redirect_to chats_path, notice: 'Chat was successfully created.' }
        format.turbo_stream { flash.now[:notice] = 'Chat was successfully created.' }
      end
    else
      render :new
    end
  end

  def update
    if @chat.update(chat_params)
      respond_to do |format|
        format.html { redirect_to chats_path, notice: 'chat was successfully updated.' }
        format.turbo_stream { flash.now[:notice] = 'chat was successfully updated.' }
      end
    else
      render :edit
    end
  end

  def edit; end

  def destroy
    if @chat.destroy

      respond_to do |format|
        format.html { redirect_to chat_path, notice: 'chat was successfully destroyed.' }
        format.turbo_stream { flash.now[:notice] = 'chat was successfully destroyed.' }
      end
    else

      respond_to do |format|
        format.html { redirect_to chat_path, notice: 'chat was successfully destroyed.' }
        format.turbo_stream { flash.now[:notice] = 'chat was successfully destroyed.' }
      end
    end
  end

  private

  def set_chat
    @chat = current_user.chats.find_by_id(params[:id])
    return if @chat

    redirect_to chats_path
  end

  def chat_params
    params.require(:chat).permit(:user_2_id)
  end
end
