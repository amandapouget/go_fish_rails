json.array!(@users) do |user|
  json.extract! user, :id, :name, :type, :think_time
  json.url user_url(user, format: :json)
end
