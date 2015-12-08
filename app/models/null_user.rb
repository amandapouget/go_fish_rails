class NullUser
  attr_accessor :matches, :name, :client

  def initialize
    @name = "none"
    @matches = []
  end

  def save
  end

  def current_match
  end

  def id
  end

  def update_attribute
  end

  def eql?(nulluser)
    nulluser.is_a? NullUser
  end

  alias == eql?

  def hash
    "hash".hash
  end
end
