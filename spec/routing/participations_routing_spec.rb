require "rails_helper"

RSpec.describe ParticipationsController, type: :routing do
  describe "routing" do
    it "routes to #index" do
      expect(:get => "/participations").to route_to("participations#index")
    end
  end
end
