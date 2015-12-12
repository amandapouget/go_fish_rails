FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :real_user do
    name { User::FAKENAMES.rotate![0] }
    email
    password "love2fish"
  end

  factory :robot_user do
    email
    think_time 0
  end
end
