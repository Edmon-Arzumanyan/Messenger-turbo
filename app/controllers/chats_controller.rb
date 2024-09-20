# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_chat, only: %i[show destroy]

  def index
    @chats = current_user.chats.kept.order(updated_at: :desc)
    @users = User.none

    @chat = session_last_chat || current_user.chats.last
    @messages = load_messages

    filter_users if params[:query].present?

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update('chats', partial: 'chats/chats_list', locals: { chats: @chats, user: current_user }),
          turbo_stream.update('users', partial: 'chats/users_list', locals: { users: @users })
        ]
      end
    end
  end

  def new
    @chat = current_user.initiated_chats.new
    exclude_chat_user_ids
  end

  def show
    session[:last_chat] = { 'id' => @chat.id }
    handle_discarded_chat if @chat.discarded?

    @message = current_user.messages.new
    @messages = load_messages

    mark_messages_as_read

    respond_to do |format|
      format.html
      format.turbo_stream do
        render turbo_stream: [
          turbo_stream.update(@chat, partial: 'chats/chat', locals: { chat: @chat, user: current_user }),
          turbo_stream.update("#{current_user.id}_show", partial: 'chats/show',
                                                         locals: { user: current_user, messages: @messages, message: @message, chat: @chat })
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

  def destroy
    if @chat.discard
      session[:last_chat] = nil
      broadcast_chat_removal
    else
      handle_destroy_failure
    end
  end

  private

  def load_messages
    if @chat.last_discarded_at.present?
      Message.after_last_discarded_at(@chat).order(:created_at)
    else
      @chat.messages.order(:created_at)
    end
  end

  def session_last_chat
    chat_id = session.dig(:last_chat, 'id')
    current_user.chats.find_by(id: chat_id) if chat_id
  end

  def set_chat
    @chat = current_user.chats.find_by(id: params[:id])
    redirect_to chats_path unless @chat
  end

  def chat_params
    params.require(:chat).permit(:user_2_id)
  end

  def filter_users
    @users = User.kept.search(params[:query])
    user_ids = @users.ids

    initiated_chats = current_user.initiated_chats.where(user_2_id: user_ids)
    received_chats = current_user.received_chats.where(user_1_id: user_ids)
    @chats = (initiated_chats + received_chats).uniq

    chat_user_ids = @chats.pluck(:user_1_id, :user_2_id).flatten.uniq
    @users = @users.where.not(id: chat_user_ids)
  end

  def exclude_chat_user_ids
    chat_user_ids = current_user.chats.pluck(:user_1_id, :user_2_id).flatten.uniq
    @users = User.kept.where.not(id: chat_user_ids)
  end

  def handle_discarded_chat
    partner = @chat.chat_partner(current_user.id)
    @chat.undiscard
    @chat.broadcast_chat_undiscard(partner) if partner
  end

  def mark_messages_as_read
    @messages.unread.where.not(user_id: current_user.id).find_each do |message|
      message.update(status: 'read')
    end
  end

  def broadcast_chat_removal
    [@chat.user_1, @chat.user_2].each do |chat_user|
      Turbo::StreamsChannel.broadcast_remove_to([chat_user, 'chats'], target: @chat)
      Turbo::StreamsChannel.broadcast_remove_to([chat_user, @chat], target: @chat)
    end
  end

  def handle_destroy_failure
    respond_to do |format|
      format.html { redirect_to chats_path, alert: 'Failed to destroy chat.' }
      format.turbo_stream { flash.now[:alert] = 'Failed to destroy chat.' }
    end
  end
end
