module Admin::ChatsHelper
  def admin_chats_table_settings
    head = [
      { name: 'Number', attribute: 'number', sortable: true, sort_column: 'number' },
      { name: 'User 1', attribute: 'user_1', sortable: true, sort_column: 'user_1' },
      { name: 'User 2', attribute: 'user_2', sortable: true, sort_column: 'user_2' },
      { name: 'Messages', attribute: 'messages', sortable: false },
      { name: 'Created At', attribute: 'created_at', sortable: true, sort_column: 'created_at' },
      { name: 'Archived At', attribute: 'discarded_at', sortable: true, sort_column: 'discarded_at' }
    ]

    body = [
      { call: lambda { |chat|
        link_to chat.number,
                admin_chat_path(chat),
                class: 'table-link'
      } },
      { call: lambda { |chat|
        link_to chat.user_1.full_name,
                admin_user_path(chat.user_1),
                class: 'table-link'
      } },
      { call: lambda { |chat|
        link_to chat.user_2.full_name,
                admin_user_path(chat.user_2),
                class: 'table-link'
      } },
      { call: lambda { |chat|
        link_to chat.messages.count,
                admin_messages_path(chat: chat.id),
                class: 'table-link'
      } },
      { call: lambda { |chat|
        chat.created_at.strftime('%Y-%m-%d %H:%M')
      } },
      { call: lambda { |chat|
        chat.discarded_at&.strftime('%Y-%m-%d %H:%M')
      } }
    ]

    {
      models: @resource,
      data: @resources,
      head:,
      body:
    }
  end

  def admin_chats_form_settings
    {
      models: [:admin, @resource],
      show_path: @resource.persisted? ? admin_chat_path(@resource) : admin_chats_path,
      edit_path: @resource.persisted? ? edit_admin_chat_path(@resource) : nil,
      fields: [
        {
          attribute: :user_1_id,
          type: :select,
          options: User.all.pluck(:email, :id),
          required: true
        },
        {
          attribute: :user_2_id,
          type: :select,
          options: User.all.pluck(:email, :id),
          required: true
        },
        {
          attribute: :last_discarded_at,
          type: :datetime_field
        }
      ]
    }
  end

  def admin_chats_filter_settings
    {
      index_path: admin_chats_path,
      fields: [
        { attribute: :query, type: :text_field, placeholder: 'Chat number or user 1 or user 2' },
        { attribute: :user_1, type: :select, options: User.all.map do |user|
          [user.full_name, user.id]
        end, prompt: 'Select User 1' },
        { attribute: :user_2, type: :select, options: User.all.map do |user|
          [user.full_name, user.id]
        end, prompt: 'Select User 2' },
        { attribute: :archive_states, type: :select,
          options: { 'All' => 'all', 'Active' => 'active', 'Archived' => 'archived' }, prompt: 'Select Archive State' },
        { attribute: :created_from, type: :date_field, placeholder: 'Created From' },
        { attribute: :created_to, type: :date_field, placeholder: 'Created To' },
        { attribute: :archived_from, type: :date_field, placeholder: 'Archived From' },
        { attribute: :archived_to, type: :date_field, placeholder: 'Archived To' }
      ]
    }
  end
end
