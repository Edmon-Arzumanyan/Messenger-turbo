require 'csv'

class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  has_paper_trail ignore: %i[last_seen_at encrypted_password], scope: -> { order('id desc') }

  has_one_attached :image, dependent: :destroy
  has_many :initiated_chats, class_name: 'Chat', foreign_key: 'user_1_id', dependent: :destroy
  has_many :received_chats, class_name: 'Chat', foreign_key: 'user_2_id', dependent: :destroy
  has_many :messages, dependent: :destroy

  after_update_commit :broadcast_user_update, unless: -> { admin }

  pg_search_scope :search,
                  against: %i[email first_name last_name],
                  using: { tsearch: { prefix: true } }

  enum role: {
    user: 0,
    admin: 99
  }

  def active_for_authentication?
    super && !discarded?
  end

  def activity
    PaperTrail::Version
      .where(whodunnit: id)
      .order(created_at: :desc)
  end

  def broadcast_user_update
    broadcast_update_to self, target: self, partial: 'chats/partner', locals: { partner: self }
    broadcast_update_to self, target: "#{id}_icon", partial: 'chats/partner_icon', locals: { partner: self }
  end

  def chats
    Chat.where('user_1_id = ? OR user_2_id = ?', id, id)
  end

  def full_name
    "#{first_name} #{last_name}".squish
  end

  def online?
    last_seen_at.present? && last_seen_at > 5.minutes.ago
  end

  def to_s
    full_name
  end

  def self.to_csv(users)
    CSV.generate(headers: true) do |csv|
      csv << %w[ID Email FirstName LastName Phone Role LastSeenAt CreatedAt UpdatedAt ChatCount MessageCount Image]

      users.find_each do |user|
        chat_count = user.chats.count
        message_count = user.messages.count

        csv << [
          user.id,
          user.email,
          user.first_name,
          user.last_name,
          user.phone,
          user.role,
          user.last_seen_at,
          user.created_at,
          user.updated_at,
          chat_count,
          message_count,
          user.image.attached? ? url_for(user.image) : nil
        ]
      end
    end
  end
end
