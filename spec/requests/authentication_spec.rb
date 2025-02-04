require 'rails_helper'

RSpec.describe 'Authentication', type: :request do
  let(:user) { Fabricate(:user, username: 'john_doe', password: 'SecurePass123!') }

  before { user.save }

  describe 'POST /login' do
    context 'when the credentials are correct' do
      it 'returns a JWT token' do
        post '/login', params: { username: 'john_doe', password: 'SecurePass123!' }

        expect(response).to have_http_status(:ok)
        expect(response.body).to include('token')
      end
    end

    context 'when the credentials are incorrect' do
      it 'returns an unauthorized error' do
        post '/login', params: { username: 'john_doe', password: 'WrongPassword' }

        expect(response).to have_http_status(:unauthorized)
        expect(response.body).to include('Invalid credentials')
      end
    end
  end
end
