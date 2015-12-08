class NullUser
  attr_accessor :matches, :name, :id

  def initialize
    @name = "none"
    @matches = []
  end

  def save
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
