require 'rails_helper'

RSpec.describe 'Admin::Users', type: :request do
  let(:admin) { create(:user, :as_admin) }
  let(:resource) { create(:user, last_seen_at: nil) }
  let(:valid_params) { { user: attributes_for(:user).merge(admin: true) } }
  let(:invalid_params) { { user: { email: nil } } }

  before do
    sign_in admin
  end

  it_behaves_like 'resourcable',
                  User,
                  :admin_users_path,
                  :admin_user_path

  describe 'GET #index filters' do
    let!(:user_1) { create(:user, last_seen_at: 2.days.ago) }
    let!(:user_2) { create(:user, last_seen_at: 5.days.ago) }
    let!(:user_3) { create(:user, last_seen_at: 1.week.ago) }

    it 'filters by last_seen_from' do
      get admin_users_path, params: { last_seen_from: 3.days.ago.to_date }

      expect(assigns(:resources)).to match_array([admin, user_1])
    end

    it 'filters by last_seen_to' do
      get admin_users_path, params: { last_seen_to: 4.days.ago.to_date }

      expect(assigns(:resources)).to match_array([user_2, user_3])
    end

    it 'filters by last_seen_from and last_seen_to' do
      get admin_users_path, params: { last_seen_from: 6.days.ago.to_date, last_seen_to: 3.days.ago.to_date }

      expect(assigns(:resources)).to match_array([user_2])
    end

    it 'filters by query' do
      get admin_users_path, params: { query: user_1.email }

      expect(assigns(:resources)).to match_array([user_1])
    end
  end

  describe '#log_in_as_user' do
    it 'sets the flash message and redirects to the root path' do
      post admin_user_login_as_path(resource)

      expect(flash[:success]).to eq("Logged in as #{resource}")
      expect(response).to redirect_to(root_path)
    end
  end
end
