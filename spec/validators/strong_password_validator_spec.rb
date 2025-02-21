require 'rails_helper'

RSpec.describe StrongPasswordValidator, type: :validator do
  class MockUser < RedisRecord
    include ActiveModel::Model

    attr_accessor :password
    validates :password, strong_password: true

    def attributes
      { password: @password }
    end
  end

  context 'when password is valid' do
    it 'does not add errors' do
      user = MockUser.new(password: 'Valid1@Password')
      user.valid?
      expect(user.errors[:password]).to be_empty
    end
  end

  context 'when password is invalid' do
    it 'adds an error when password is too short' do
      user = MockUser.new(password: 'Short1@')
      user.valid?
      expect(user.errors[:password]).to include("must include at least one uppercase letter, one number, and one special character")
    end

    it 'adds an error when password has no uppercase letter' do
      user = MockUser.new(password: 'lowercase1@')
      user.valid?
      expect(user.errors[:password]).to include("must include at least one uppercase letter, one number, and one special character")
    end

    it 'adds an error when password has no number' do
      user = MockUser.new(password: 'NoNumber@Uppercase')
      user.valid?
      expect(user.errors[:password]).to include("must include at least one uppercase letter, one number, and one special character")
    end

    it 'adds an error when password has no special character' do
      user = MockUser.new(password: 'NoSpecial1Uppercase')
      user.valid?
      expect(user.errors[:password]).to include("must include at least one uppercase letter, one number, and one special character")
    end
  end
end
