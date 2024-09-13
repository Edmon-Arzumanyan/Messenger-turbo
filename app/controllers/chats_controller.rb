# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: %i[show destroy]

  def index
    @chats = current_user.chats.kept.order(updated_at: :desc)
    @users = User.none

    if params[:query].present?
      @users = User.kept.search(params[:query])
      user_ids = @users.ids

      initiated_chats = current_user.initiated_chats.where(user_2_id: user_ids)
      received_chats = current_user.received_chats.where(user_1_id: user_ids)
      @chats = (initiated_chats + received_chats).uniq

      chat_user_ids = @chats.pluck(:user_1_id, :user_2_id).flatten.uniq
      @users = @users.where.not(id: chat_user_ids)
    end

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(
            'chats',
            partial: 'chats/chats_list',
            locals: { chats: @chats, user: current_user }
          ),
          turbo_stream.update(
            'users',
            partial: 'chats/users_list',
            locals: { users: @users }
          )
        ]
      end
    end
  end

  def new
    @chat = current_user.initiated_chats.new
    chat_user_ids = current_user.chats.pluck(:user_1_id, :user_2_id).flatten.uniq
    @users = User.kept.where.not(id: chat_user_ids)
  end

  def show
    @chat.undiscard if @chat.discarded?
    @message = current_user.messages.new

    @messages = if @chat.last_discared_at.present?
                  Message.after_last_discared_at(@chat).order(:created_at)
                else
                  @chat.messages.order(:created_at)
                end

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
            locals: { user: current_user,
                      messages: @messages,
                      message: @message,
                      chat: @chat }
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
        format.turbo_stream
      end
    else
      render :new
    end
  end

  # def update
  #   if @chat.update(chat_params)
  #     respond_to do |format|
  #       format.html { redirect_to chats_path, notice: 'chat was successfully updated.' }
  #       format.turbo_stream { flash.now[:notice] = 'chat was successfully updated.' }
  #     end
  #   else
  #     render :edit
  #   end
  # end

  # def edit; end

  def destroy
    if @chat.discard
      [@chat.user_1, @chat.user_2].each do |chat_user|
        Turbo::StreamsChannel.broadcast_remove_to([chat_user, 'chats'], target: @chat)
        Turbo::StreamsChannel.broadcast_remove_to([chat_user, @chat], target: @chat)
      end
    else
      respond_to do |format|
        format.html { redirect_to chats_path, alert: 'Failed to destroy chat.' }
        format.turbo_stream do
          flash.now[:alert] = 'Failed to destroy chat.'
        end
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
