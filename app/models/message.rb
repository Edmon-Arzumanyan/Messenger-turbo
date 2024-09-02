class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :chat
  has_many_attached :files, dependent: :destroy

  validates :body, presence: true, unless: -> { files.attached? }

  after_create_commit :mark_chat_as_read, :broadcast_message_to_users, :update_chat_display

  enum status: { unread: 0, read: 1 }

  private

  def mark_chat_as_read
    chat.messages.unread.where.not(user_id: user.id).update_all(status: 'read')
  end

  def broadcast_message_to_users
    [chat.user_1, chat.user_2].each do |chat_user|
      broadcast_append_to [chat_user, chat, 'messages'], partial: 'messages/message',
                                                         locals: { message: self, user: chat_user }
    end
  end

  def update_chat_display
    [chat.user_1, chat.user_2].each do |chat_user|
      broadcast_update_to "#{chat_user.id}_#{dom_id(chat)}",
                          target: "#{chat_user.id}_#{dom_id(chat)}",
                          partial: 'chats/chat',
                          locals: { chat:, user: chat_user.id }
    end
  end
end
