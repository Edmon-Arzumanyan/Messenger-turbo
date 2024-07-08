# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :user_1, class_name: 'User', foreign_key: 'user_1_id'
  belongs_to :user_2, class_name: 'User', foreign_key: 'user_2_id'

  validates :user_1_id, uniqueness: { scope: :user_2_id }

  def title(current_user_id)
    if user_1_id == current_user_id
      user_2.email
    elsif user_2_id == current_user_id
      user_1.email
    else
      ''
    end
  end

  after_create_commit do
    broadcast_prepend_to [user_2, 'chats'], partial: 'chats/chat', locals: { chat: self, user:  user_2.id }
    broadcast_prepend_to [user_1, 'chats'], partial: 'chats/chat', locals: { chat: self, user:  user_1.id }
  end

  after_destroy_commit do
    broadcast_remove_to [user_2, 'chats']
    broadcast_remove_to [user_1, 'chats']
  end

  after_update_commit do
    broadcast_replace_to [user_2, 'chats'], partial: 'chats/chat', locals: { chat: self, user: user_2.id }
    broadcast_replace_to [user_1, 'chats'], partial: 'chats/chat', locals: { chat: self, user: user_1.id }
  end

  # broadcasts_to ->(chat) { [(chat.user_2 || chat.user_1), 'chats'] }, inserts_by: :prepend
end
