ap users = FactoryBot.create_list(:user, 20)

users.each do |user|
  chats = []

  5.times do
    excluded_user_ids = user.chats.pluck(:user_2_id).uniq
    user_2_candidates = User.where.not(id: [user.id, *excluded_user_ids])

    next if user_2_candidates.empty?

    user_2 = user_2_candidates.sample

    next if Chat.exists?(user_1: user, user_2:) || Chat.exists?(user_1: user_2, user_2: user)

    ap chat = FactoryBot.create(:chat, user_1: user, user_2:)

    chats << chat

    5.times do
      ap FactoryBot.create(:message, chat:, user: chat.user_1)
      ap FactoryBot.create(:message, chat:, user: chat.user_2)
    end
  end
end
