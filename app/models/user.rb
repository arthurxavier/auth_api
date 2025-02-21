class User < RedisRecord
  include ActiveModel::Model
  include ActiveModel::Validations
  include Authenticatable

  attr_accessor :username

  identifier :username

  validates :username, presence: true, uniqueness: true
  validates :password, strong_password: true

  def attributes
    { username: @username, password_hash: @password_hash, password: @password }
  end

  def save
    prepare_for_save
    super
  end
end
