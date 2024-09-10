FactoryBot.define do
  factory :chat do
    association :user_1, factory: :user
    association :user_2, factory: :user
  end
end
