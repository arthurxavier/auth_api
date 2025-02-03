require 'rails_helper'

RSpec.describe Authenticatable do
  class Dummy < RedisRecord
    include ActiveModel::Model
    include ActiveModel::Validations
    include Authenticatable

    attr_accessor :username

    def attributes
      { username: @username, password_hash: @password_hash, password: @password }
    end

    def save
      prepare_for_save
      self.class.set(attributes)
    end
  end

  let(:dummy) { Dummy.new(username: 'test_dummy', password: 'SecurePass123!') }

  describe '#authenticate' do
    it 'returns true when the password matches' do
      dummy.save
      expect(dummy.authenticate('SecurePass123!')).to be true
    end

    it 'returns false when the password does not match' do
      dummy.save
      expect(dummy.authenticate('WrongPass!')).to be false
    end
  end

  describe '#encrypt_password' do
    it 'encrypts the password before saving' do
      expect(dummy.password_hash).to be_nil
      dummy.save
      expect(dummy.password_hash).not_to be_nil
      expect(dummy.password_hash.class).to eq(BCrypt::Password)
      expect(dummy.password_hash.to_s).not_to eq(dummy.password)
    end
  end
end
