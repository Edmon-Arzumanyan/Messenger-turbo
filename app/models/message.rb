class Message < ApplicationRecord
  has_ancestry

  belongs_to :user
  belongs_to :chat
  has_many_attached :files, dependent: :destroy

  validates :body, presence: true, unless: -> { files.attached? }

  after_create_commit :mark_chat_as_read, :broadcast_message_to_users, :update_chat_display
  after_update_commit :broadcast_message_update
  # after_destroy_commit :broadcast_message_remove

  enum status: { unread: 0, read: 1 }

  scope :after_last_discared_at, lambda { |chat|
    where('created_at > ?', chat.last_discared_at)
  }

  private

  def mark_chat_as_read
    chat.messages.unread.where.not(user_id: user.id).update(status: 'read')
  end

  def broadcast_to_users(&block)
    return unless chat

    [chat.user_1, chat.user_2].each do |chat_user|
      block.call(chat_user)
    end
  end

  def broadcast_message_to_users
    broadcast_to_users do |chat_user|
      broadcast_append_to [chat_user, chat, 'messages'], partial: 'messages/message',
                                                         locals: { message: self, user: chat_user }
    end
  end

  def update_chat_display
    broadcast_to_users do |chat_user|
      broadcast_update_to [chat_user, chat],
                          target: chat,
                          partial: 'chats/chat',
                          locals: { chat:, user: chat_user }
    end
  end

  # def broadcast_message_remove
  #   broadcast_to_users do |chat_user|
  #     broadcast_remove_to [chat_user, self], target: self
  #   end
  # end

  def broadcast_message_update
    broadcast_to_users do |chat_user|
      broadcast_update_to [chat_user, self], target: self,
                                             partial: 'messages/message',
                                             locals: { message: self, user: chat_user }
    end
  end
end
