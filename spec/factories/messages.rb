FactoryBot.define do
  factory :message do
    association :user
    association :chat
    body { Faker::Lorem.sentence }
    status { Message.statuses.keys.sample }
    is_edited { Faker::Boolean.boolean }
  end
end
