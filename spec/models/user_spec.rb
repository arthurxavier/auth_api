# spec/models/user_spec.rb
require 'rails_helper'

RSpec.describe User, type: :model do
  let(:valid_user) { Fabricate(:user) }

  after(:each) do
    # TODO: Avoid using $redis.flushdb directly here.
    # TODO: Maybe configure a more specific cleaner for Redis.
    $redis.flushdb
  end

  context 'validations' do
    context 'when the user has valid attributes' do
      it 'is valid with a username and a strong password' do
        expect(valid_user).to be_valid
      end
    end

    context 'when the user is missing required attributes' do
      it 'is invalid without a username' do
        user = Fabricate.build(:user, username: nil)
        expect(user).not_to be_valid
        expect(user.errors[:username]).to include("can't be blank")
      end

      it 'is invalid without a password' do
        user = Fabricate.build(:user, password: nil)
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include("can't be blank")
      end
    end

    context 'when the password is invalid' do
      it 'is invalid with a short password' do
        user = Fabricate.build(:user, password: 'short')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character')
      end

      it 'is invalid with a password without an uppercase letter' do
        user = Fabricate.build(:user, password: 'lowercase1!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character')
      end

      it 'is invalid with a password without a number' do
        user = Fabricate.build(:user, password: 'NoNumber!')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character')
      end

      it 'is invalid with a password without a special character' do
        user = Fabricate.build(:user, password: 'NoSpecial1')
        expect(user).not_to be_valid
        expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character')
      end
    end

    context 'when the username is invalid' do
      it 'is invalid with a non-unique username' do
        user1 = Fabricate(:user)
        user1.save
        user2 = Fabricate.build(:user, username: user1.username)
        expect(user2).not_to be_valid
        expect(user2.errors[:username]).to include('has already been taken')
      end
    end
  end
end
