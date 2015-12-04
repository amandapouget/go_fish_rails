FactoryGirl.define do
  # factory :match do
  #   over false
  #   message "MyText"
  #   hand_size 1
  #   game "MyText"
  # end

  factory :match do
    transient do
      num_players { Game::MIN_PLAYERS }
    end
    users { create_list(:real_user, num_players) }

    trait :dealt do
      after(:create) do |match|
        match.game.deal
        match.save
      end
    end
  end
end
