# frozen_string_literal: true

class Chat < ApplicationRecord
  belongs_to :user_1, class_name: 'User', foreign_key: 'user_1_id'
  belongs_to :user_2, class_name: 'User', foreign_key: 'user_2_id'
  has_many :messages, dependent: :destroy

  validate :unique_user_pair

  after_create_commit :broadcast_chat_prepend
  after_discard :update_last_discarded_at
  # after_destroy_commit :broadcast_chat_remove

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
    if last_discared_at.present?
      Message.after_last_discared_at(self).unread.where.not(user_id:).count
    else
      messages.unread.where.not(user_id:).count
    end
  end

  def broadcast_chat_undiscard(partner)
    broadcast_prepend_to [partner, 'chats'], partial: 'chats/chat', locals: { chat: self, user: partner }
  end

  private

  def broadcast_chat_prepend
    [user_1, user_2].uniq.each do |chat_user|
      broadcast_prepend_to [chat_user, 'chats'], partial: 'chats/chat', locals: { chat: self, user: chat_user }
    end
  end

  # def broadcast_chat_remove
  #   [user_1, user_2].each do |chat_user|
  #     broadcast_remove_to [chat_user, 'chats'], target: self
  #     broadcast_remove_to [chat_user, self], target: self
  #   end
  # end

  def unique_user_pair
    if self.class.where('user_1_id = ? AND user_2_id = ?', user_1_id, user_2_id).exists? ||
       self.class.where('user_1_id = ? AND user_2_id = ?', user_2_id, user_1_id).exists?
      errors.add(:base, 'The combination of user_1_id and user_2_id must be unique.')
    end
  end

  def update_last_discarded_at
    update_column(:last_discared_at, discarded_at) if discarded_at
  end
end
