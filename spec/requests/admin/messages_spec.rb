require 'rails_helper'

RSpec.describe 'Admin::Messages', type: :request do
  let(:admin) { create(:user, :as_admin) }
  let(:user) { create(:user) }
  let(:chat) { create(:chat) }
  let(:resource) { create(:message) }
  let(:valid_params) { { message: attributes_for(:message).merge(user_id: user.id, chat_id: chat.id, admin: true) } }
  let(:invalid_params) { { message: { body: nil } } }

  let(:message_1) { create(:message, user:, chat:, status: 'unread', body: 'Test message 1') }
  let(:message_2) { create(:message, user:, chat:, status: 'read', body: 'Test message 2') }
  let(:message_3) { create(:message, status: 'unread', body: 'Test message 3') }

  before do
    sign_in admin
  end

  it_behaves_like 'resourcable',
                  Message,
                  :admin_messages_path,
                  :admin_message_path

  describe 'GET #index filters' do
    let!(:message_1) { create(:message, user:, chat:, status: 'unread', body: 'Test message 1') }
    let!(:message_2) { create(:message, user:, chat:, status: 'read', body: 'Test message 2') }
    let!(:message_3) { create(:message, status: 'unread', body: 'Test message 3') }

    it 'filters by query' do
      get admin_messages_path, params: { query: 'Test message 1' }

      expect(assigns(:resources)).to match_array([message_1])
    end

    it 'filters by user' do
      get admin_messages_path, params: { user: user.id }

      expect(assigns(:resources)).to match_array([message_1, message_2])
    end

    it 'filters by chat' do
      get admin_messages_path, params: { chat: chat.id }

      expect(assigns(:resources)).to match_array([message_1, message_2])
    end

    it 'filters by status' do
      get admin_messages_path, params: { status: 'unread' }

      expect(assigns(:resources)).to match_array([message_1, message_3])
    end

    it 'filters by multiple parameters' do
      get admin_messages_path, params: { user: user.id, chat: chat.id, status: 'read' }

      expect(assigns(:resources)).to match_array([message_2])
    end
  end
end
