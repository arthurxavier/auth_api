require 'rails_helper'

RSpec.describe 'Users', type: :request do
  describe 'POST /users' do
    context 'when the user is valid' do
      it 'creates a user and returns a success message' do
        post '/users', params: { user: { username: 'john_doe', password: 'SecurePass123!' } }

        expect(response).to have_http_status(:created)
        expect(response.body).to include('User created successfully')
      end
    end

    context 'when the user is invalid' do
      it 'returns an error message' do
        post '/users', params: { user: { username: '', password: 'SecurePass123!' } }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response.body).to include("Username can't be blank")
      end
    end
  end

  describe 'GET /users' do
    let(:user1) { Fabricate(:user, username: 'john_doe') }
    let(:user2) { Fabricate(:user, username: 'jane_doe') }

    before do
      user1.save
      user2.save
    end

    it 'returns a list of users' do
      get '/users'

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('john_doe', 'jane_doe')
    end
  end

  describe 'GET /users/:id' do
    let(:user) { Fabricate(:user, username: 'john_doe') }

    before { user.save }

    it 'returns the details of a user' do
      get "/users/#{user.username}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('john_doe')
    end
  end

  describe 'DELETE /users/:id' do
    let(:user) { Fabricate(:user, username: 'john_doe') }

    before { user.save }

    it 'deletes a user and returns a success message' do
      delete "/users/#{user.username}"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include('User deleted successfully')
    end
  end
end
