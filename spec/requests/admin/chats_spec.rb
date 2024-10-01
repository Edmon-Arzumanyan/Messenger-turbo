require 'rails_helper'

RSpec.describe 'Admin::Chats', type: :request do
  let(:admin) { create(:user, :as_admin) }
  let(:user_1) { create(:user) }
  let(:user_2) { create(:user) }
  let(:resource) { create(:chat) }
  let(:valid_params) { { chat: attributes_for(:chat).merge(admin: true, user_1_id: user_1.id, user_2_id: user_2.id) } }
  let(:invalid_params) { { chat: { user_1_id: nil } } }

  before do
    sign_in admin
  end

  it_behaves_like 'resourcable',
                  Chat,
                  :admin_chats_path,
                  :admin_chat_path

  describe 'GET #index filters' do
    let!(:chat_1) { create(:chat, user_1:, user_2:) }
    let!(:chat_2) { create(:chat, user_1:) }
    let!(:chat_3) { create(:chat, user_2:) }

    it 'filters by user_1' do
      get admin_chats_path, params: { user_1: user_1.id }, as: :json

      expect(assigns(:resources)).to match_array([chat_1, chat_2])
    end

    it 'filters by user_2' do
      get admin_chats_path, params: { user_2: user_2.id }

      expect(assigns(:resources)).to match_array([chat_1, chat_3])
    end

    it 'filters by both user_1 and user_2' do
      get admin_chats_path, params: { user_1: user_1.id, user_2: user_2.id }

      expect(assigns(:resources)).to match_array([chat_1])
    end

    it 'filters by query' do
      get admin_chats_path, params: { query: chat_1.number }

      expect(assigns(:resources)).to match_array([chat_1])
    end
  end
end
