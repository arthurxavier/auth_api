# The `Authenticatable` module provides password encryption and authentication.
# It encrypts passwords using BCrypt and includes validation for strong passwords.
#
# Features:
# - Encrypts passwords before saving
# - Provides an `authenticate` method to verify credentials
# - Ensures password strength through validations
#
# Usage:
#   class User < RedisRecord
#     include Authenticatable
#     attr_accessor :username
#   end
#
#   user = User.new(username: 'john_doe', password: 'SecurePass123!')
#   user.save
#   user.authenticate('SecurePass123!') # => true
#   user.authenticate('WrongPass!')     # => false

module Authenticatable
  extend ActiveSupport::Concern

  included do
    attr_accessor :password   # `password` is the temporary field that stores the plain-text password
    attr_accessor :password_hash  # `password_hash` stores the encrypted password hash
    validates :password, presence: true, strong_password: true
  end

  def authenticate(password)
    BCrypt::Password.new(self.password_hash) == password
  end

  def password=(password)
    @password = password
    self.password_hash = BCrypt::Password.create(password) if password.present?
  end

  def prepare_for_save
    # Encrypt the password before saving
    encrypt_password
  end

  private

  def encrypt_password
    self.password_hash = BCrypt::Password.create(@password) if @password.present?
  end
end
