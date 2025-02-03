require 'rails_helper'

RSpec.describe User, type: :model do
  after(:each) do
    # TODO: Avoid using $redis.flushdb directly here.
    # TODO: Maybe configure a more specific cleaner for Redis.
    $redis.flushdb
  end

  let(:username) { 'arthur' }
  let(:password) { 'SecurePass123!' }
  let(:user) { Fabricate.build(:user, username: username, password: password) }

  subject { user }

  describe 'validations' do
    context 'when the user has valid attributes' do
      it { is_expected.to be_valid }
    end

    context 'when the user is missing required attributes' do
      before { user.valid? } # Executa a validação antes dos testes

      context 'without a username' do
        let(:username) { nil }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:username]).to include("can't be blank") }
      end

      context 'without a password' do
        let(:password) { nil }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:password]).to include("can't be blank") }
      end
    end

    context 'when the password is invalid' do
      before { user.valid? }

      context 'with a short password' do
        let(:password) { 'short' }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character') }
      end

      context 'without an uppercase letter' do
        let(:password) { 'lowercase1!' }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character') }
      end

      context 'without a number' do
        let(:password) { 'NoNumber!' }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character') }
      end

      context 'without a special character' do
        let(:password) { 'NoSpecial1' }

        it { is_expected.not_to be_valid }
        it { expect(user.errors[:password]).to include('must include at least one uppercase letter, one number, and one special character') }
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

    context 'when the username is not unique' do
      let!(:existing_user) { Fabricate(:user, username: username) }

      before do
        existing_user.save
        user.valid?
      end

      it { is_expected.not_to be_valid }
      it { expect(user.errors[:username]).to include('has already been taken') }
    end
  end

  describe '#authenticate' do
    before { user.save }

    it 'returns true for the correct password' do
      expect(user.authenticate(password)).to be true
    end

    it 'returns false for an incorrect password' do
      expect(user.authenticate('WrongPass!')).to be false
    end
  end

  describe '#save' do
    it 'encrypts the password' do
      expect(user.password_hash).to be_nil
      user.save
      expect(user.password_hash).not_to be_nil
      expect(user.password_hash.to_s).not_to eq(user.password)
    end
  end
end
