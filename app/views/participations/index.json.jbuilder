json.array!(@participations) do |participation|
  json.extract! participation, :id, :match_id, :user_id
  json.url participation_url(participation, format: :json)
end
