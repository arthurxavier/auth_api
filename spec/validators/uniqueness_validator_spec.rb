require 'rails_helper'

RSpec.describe UniquenessValidator, type: :validator do
  class MockUser < RedisRecord
    include ActiveModel::Model
    include ActiveModel::Validations

    attr_accessor :name
    validates :name, uniqueness: true

    identifier :name

    def attributes
      { name: @name }
    end
  end

  before do
    MockUser.create(name: 'arthur')
  end

  after do
    $redis.flushdb
  end

  describe 'validating uniqueness' do
    context 'when the attribute is unique' do
      let(:new_user) { MockUser.new(name: 'victor') }

      it 'does not add any errors' do
        new_user.valid?

        expect(new_user.errors[:name]).to be_empty
      end
    end

    context 'when the attribute is not unique' do
      let(:duplicate_user) { MockUser.new(name: 'arthur') }

      it 'adds an error if the attribute already exists' do
        duplicate_user.valid?

        expect(duplicate_user.errors[:name]).to include('has already been taken')
      end
    end
  end
end
