class User < RedisRecord
  include ActiveModel::Model
  include ActiveModel::Validations

  attr_accessor :username, :password

  identifier :username

  validates :username, presence: true, uniqueness: true
  validates :password, presence: true, strong_password: true

  def attributes
    { username: @username, password: @password }
  end
end
