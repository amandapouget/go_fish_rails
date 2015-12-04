json.array!(@matches) do |match|
  json.extract! match, :id, :over, :message, :hand_size, :game
  json.url match_url(match, format: :json)
end
