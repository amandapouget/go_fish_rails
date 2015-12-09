FactoryGirl.define do
  factory :user do
    name { User::FAKENAMES.rotate![0] }
    type "RealUser"
  end

  factory :real_user do
    name { User::FAKENAMES.rotate![0] }
  end

  factory :robot_user do
    think_time 0
  end
end
