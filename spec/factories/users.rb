FactoryBot.define do
  factory :user do
    role { 'user' }
    email { Faker::Internet.email }
    first_name { Faker::Name.first_name }
    last_name { Faker::Name.last_name }
    phone { Faker::PhoneNumber.phone_number }
    password { 'password' }
  end
end
