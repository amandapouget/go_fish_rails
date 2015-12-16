FactoryGirl.define do
  factory :real_user do
    name { User::FAKENAMES.rotate![0] }
    email { "email#{(Time.now.to_f * 100000).to_i}@gofish.com" }
    password "love2fish"
  end

  factory :robot_user do
    think_time 0
  end
end
