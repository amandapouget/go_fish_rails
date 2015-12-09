require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:real_user) }
  let(:match) { create(:match, users: [user, create(:robot_user)]) }
  let(:match2) { create(:match, users: [user, create(:robot_user)]) }

  it 'knows how many points it has earned' do
    allow(match.game).to receive(:winner).and_return(match.player(user))
    allow(match2.game).to receive(:winner).and_return(match2.player(user))
    expect { match.end_match }.to change { user.points }
    expect { match2.end_match }.to change { user.points }
  end
end
