class Message < ApplicationRecord
  include ActionView::RecordIdentifier

  belongs_to :user
  belongs_to :chat
  has_many_attached :files, dependent: :destroy

  validates :body, presence: true, unless: -> { files.attached? }


  after_create_commit do
    broadcast_append_to [chat.user_2, 'messages'], partial: 'messages/message', locals: { message: self, user: chat.user_2 }
    broadcast_append_to [chat.user_1, 'messages'], partial: 'messages/message', locals: { message: self, user: chat.user_1 }
    # broadcast_replace_to "#{chat.user_2.id}_#{dom_id(chat)}", partial: 'chats/chat', target:"#{chat.user_2.id}_#{dom_id(chat)}" , locals: { chat: chat, user: chat.user_2.id }
    # broadcast_replace_to "#{chat.user_1.id}_#{dom_id(chat)}", partial: 'chats/chat', target:"#{chat.user_1.id}_#{dom_id(chat)}", locals: { chat: chat, user: chat.user_1.id }
  end

    enum status: { unread: 0, read: 1 }
end
