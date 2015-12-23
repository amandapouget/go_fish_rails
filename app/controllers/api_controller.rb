class ApiController < MatchesController
  skip_before_action :verify_authenticity_token, :authenticate_user!
  before_action :authenticate_user_from_token!, except: [:authenticate]

  # POST /api/authenticate
  def authenticate
    password_correct = false
    authenticate_with_http_basic do |email, password|
      @user = User.find_by_email(email)
      password_correct = @user.valid_password?(password) if @user
    end
    return render json: { error: 'Invalid email or password' }, status: :unauthorized unless password_correct
  end

  def authenticate_user_from_token!
    authenticate_with_http_token do |token|
      user = User.find_by_authentication_token(token)
      sign_in user, store: false and return current_user if user
    end
    render json: { error: 'Invalid token' }, status: :unauthorized
  end
end
