# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :user_1, class_name: 'User', foreign_key: 'user_1_id'
  belongs_to :user_2, class_name: 'User', foreign_key: 'user_2_id'
  has_many :messages, dependent: :destroy

  validates :user_1_id, uniqueness: { scope: :user_2_id }

  after_create_commit :broadcast_chat_prepend
  after_destroy_commit :broadcast_chat_remove
  after_update_commit :broadcast_chat_update

  def chat_partner(current_user_id)
    if user_1_id == current_user_id
      user_2
    elsif user_2_id == current_user_id
      user_1
    else
      nil
    end
  end


  def unread_messages_count(user_id)
    messages.unread.where.not(user_id:).count
  end

  private

  def broadcast_chat_prepend
    [user_1, user_2].each_with_index do |chat_user, index|
      next if index == 1 && user_1 == user_2

      broadcast_prepend_to [chat_user, 'chats'], partial: 'chats/chat', locals: { chat: self, user: chat_user }
    end
  end


  def broadcast_chat_remove
    [user_1, user_2].each do |chat_user|
      broadcast_remove_to [chat_user, 'chats'], target: self
      broadcast_remove_to [chat_user, self], target: self
    end
  end

  def broadcast_chat_update
    [user_1, user_2].each do |chat_user|
      broadcast_update_to [chat_user, self], partial: 'chats/chat',
                                                              locals: { chat: self, user: chat_user }
    end
  end
end
