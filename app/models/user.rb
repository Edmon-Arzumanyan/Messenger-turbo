# frozen_string_literal: true

class User < ApplicationRecord
  include PgSearch::Model

  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_one_attached :image
  has_many :initiated_chats, class_name: 'Chat', foreign_key: 'user_1_id'
  has_many :received_chats, class_name: 'Chat', foreign_key: 'user_2_id'
  has_many :messages, dependent: :destroy

  after_update_commit :broadcast_user_update

  pg_search_scope :search,
                  against: %i[email first_name last_name],
                  using: { tsearch: { prefix: true } }

  def full_name
    "#{first_name} #{last_name}".squish
  end

  def chats
    Chat.where('user_1_id = ? OR user_2_id = ?', id, id)
  end

  def online?
    last_seen_at.present? && last_seen_at > 5.minutes.ago
  end

  def broadcast_user_update
    broadcast_update_to self, target: self, partial: 'chats/partner', locals: { partner: self }
    broadcast_update_to self, target: "#{id}_icon", partial: 'chats/partner_icon', locals: { partner: self }
  end
end
