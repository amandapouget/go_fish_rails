if @user
  json.user do
    json.extract!(@user, :email, :authentication_token)
  end
else
  json.error "invalid email or password"
end
