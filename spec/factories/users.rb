FactoryGirl.define do
  sequence :email do |n|
    "email#{n}@factory.com"
  end

  factory :user do
    name { User::FAKENAMES.rotate![0] }
    type "RealUser"
    email
    password "love2fish"
  end

  factory :real_user do
    name { User::FAKENAMES.rotate![0] }
    email
    password "love2fish"
  end

  factory :robot_user do
    think_time 0
    email
    password "love2fish"
  end
end
