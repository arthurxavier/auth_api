class User < RedisRecord
  include ActiveModel::Model
  include ActiveModel::Validations
  include Authenticatable

  attr_accessor :username

  identifier :username

  validates :username, presence: true, uniqueness: true

  def attributes
    { username: @username, password_hash: @password_hash, password: @password }
  end

  def save
    prepare_for_save  # Chama o "callback" manualmente antes de salvar
    self.class.set(attributes)
  end
end
