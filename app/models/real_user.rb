class RealUser < User
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates :name, presence: true
  before_save :ensure_authentication_token

  def ensure_authentication_token
    if authentication_token.blank?
      self.authentication_token = generate_authentication_token
    end
  end

  def generate_authentication_token
    loop do
      token = Devise.friendly_token
      break token unless User.where(authentication_token: token).first
    end
  end
end


# Ken's code for saving a TCP socket to a User model that lives in the database (for the purpose of reconnecting disconnected users with a now-deprecated self-built server outside of rails)
# after_save :cache_client
#
# def write_attribute(attribute, value)
#   self.client = value if (attribute == 'client')
#   super
# end
#
# def client=(client)
#   @client = client
#   cache_client
# end
#
# def client
#   if new_record?
#     @client
#   else
#     clients[id]
#   end
# end
#
# def cache_client
#   clients[id] = @client unless new_record?
# end
#
# private
#
# def clients
#   @@clients ||= {}
# end
