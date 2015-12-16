require "rails_helper"

RSpec.describe MatchesController, type: :routing do
  describe "routing" do

    it "routes to #index" do
      expect(:get => "/matches").to route_to("matches#index")
    end

    it "routes to #new" do
      expect(:get => "/matches/new").to route_to("matches#new")
    end

    it "routes to #show" do
      expect(:get => "/matches/1").to route_to("matches#show", :id => "1")
    end

    it "routes to #create" do
      expect(:post => "/matches").to route_to("matches#create")
    end

    it "routes to #update via PUT" do
      expect(:put => "/matches/1").to route_to("matches#update", :id => "1")
    end

    it "routes to #update via PATCH" do
      expect(:patch => "/matches/1").to route_to("matches#update", :id => "1")
    end

    it "routes to #start_with_robots via POST" do
      expect(:post => "/start_with_robots").to route_to("matches#start_with_robots", :num_players => "2")
    end

    it "routes to subscribed via POST" do
      expect(:post => "/subscribed").to route_to("matches#subscribed")
    end
  end
end
