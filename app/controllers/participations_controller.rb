class ParticipationsController < ApplicationController
  # GET /participations
  # GET /participations.json
  def index
    @participations = Participation.all
  end
end
