# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :initiated_chats, class_name: 'Chat', foreign_key: 'user_1_id'
  has_many :received_chats, class_name: 'Chat', foreign_key: 'user_2_id'
  has_many :messages, dependent: :destroy

  def chats
    Chat.where('user_1_id = ? OR user_2_id = ?', id, id)
  end
end
