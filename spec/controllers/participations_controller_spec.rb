require 'rails_helper'

RSpec.describe ParticipationsController, type: :controller do
  let(:current_user) { create(:real_user) }

  before do
    sign_in current_user
  end

  describe "GET #index" do
    it "assigns all participations as @participations" do
      participation = create(:participation)
      get :index
      expect(assigns(:participations)).to eq([participation])
    end
  end
end
