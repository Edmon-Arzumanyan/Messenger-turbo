# frozen_string_literal: true

class Chat < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user_1, class_name: 'User', foreign_key: 'user_1_id'
  belongs_to :user_2, class_name: 'User', foreign_key: 'user_2_id'
  has_many :messages, dependent: :destroy

  validates :user_1_id, uniqueness: { scope: :user_2_id }

  after_create_commit :broadcast_chat_prepend
  after_destroy_commit :broadcast_chat_remove
  after_update_commit :broadcast_chat_replace

  def title(current_user_id)
    if user_1_id == current_user_id
      user_2.email
    elsif user_2_id == current_user_id
      user_1.email
    else
      ''
    end
  end

  def unread_messages_count(user_id)
    messages.unread.where.not(user_id: user_id).count
  end

  private

  def broadcast_chat_prepend
    [user_1, user_2].each do |chat_user|
      broadcast_prepend_to [chat_user, 'chats'], partial: 'chats/chat', locals: { chat: self, user: chat_user.id }
    end
  end

  def broadcast_chat_remove
    [user_1, user_2].each do |chat_user|
      frame_id = "#{chat_user.id}_#{dom_id(self)}"
      broadcast_remove_to [chat_user, 'chats'], target: frame_id
    end
  end


  def broadcast_chat_replace
    [user_1, user_2].each do |chat_user|
      broadcast_replace_to  "#{chat_user.id}_#{dom_id(chat)}", partial: 'chats/chat', locals: { chat: self, user: chat_user.id }
    end
  end
end
