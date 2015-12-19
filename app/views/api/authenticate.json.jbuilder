json.user do
  json.extract!(@user, :email, :authentication_token)
end
