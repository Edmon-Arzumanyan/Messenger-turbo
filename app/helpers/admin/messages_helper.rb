module Admin::MessagesHelper
  def admin_messages_table_settings
    head = [
      { name: 'Show', sortable: false },
      { name: 'Body', attribute: 'body', sortable: true, sort_column: 'body' },
      { name: 'User', attribute: 'user', sortable: true, sort_column: 'user' },
      { name: 'Chat', attribute: 'chat', sortable: true, sort_column: 'chat' },
      { name: 'Created At', attribute: 'created_at', sortable: true, sort_column: 'created_at' },
      { name: 'Archived At', attribute: 'discarded_at', sortable: true, sort_column: 'discarded_at' }
    ]

    body = [
      { call: ->(message) { link_to message, admin_message_path(message), class: 'table-link' } },
      { call: ->(message) { message.body.truncate(100) } },
      { call: ->(message) { link_to message.user.full_name, admin_user_path(message.user), class: 'table-link' } },
      { call: ->(message) { link_to message.chat.number, admin_chat_path(message.chat), class: 'table-link' } },
      { call: ->(message) { message.created_at.strftime('%Y-%m-%d %H:%M') } },
      { call: ->(message) { message.discarded_at&.strftime('%Y-%m-%d %H:%M') } }
    ]

    {
      models: @resource,
      data: @resources,
      head:,
      body:
    }
  end

  def admin_messages_form_settings
    form_settings = {
      models: [:admin, @resource],
      show_path: @resource.persisted? ? admin_message_path(@resource) : admin_messages_path,
      edit_path: @resource.persisted? ? edit_admin_message_path(@resource) : nil,
      fields: [
        { attribute: :chat_id, type: :select, options: Chat.pluck(:number, :id), required: true },
        { attribute: :user_id, type: :select, options: User.pluck(:email, :id), required: true },
        {
          attribute: :parent_id,
          type: :select,
          options: if @resource&.persisted?
                     [''] + @resource.chat&.messages&.pluck(:body, :id)
                   else
                     [''] + Message.all.pluck(:body, :id)
                   end
        },
        { attribute: :is_edited, type: :select, options: [true, false] },
        { attribute: :status, type: :select, options: Message.statuses.keys },
        { attribute: :body, type: :text_field }
      ]
    }

    if current_page?(new_admin_message_path) || @resource.persisted? && current_page?(edit_admin_message_path(@resource))
      form_settings[:fields] << { attribute: :files, type: :file_field, multiple: true }
    end

    form_settings
  end

  def admin_messages_filter_settings
    {
      index_path: admin_messages_path,
      fields: [
        { attribute: :query, type: :text_field, placeholder: 'Search by body or user' },
        { attribute: :user, type: :select, options: User.all.map { |u| [u.full_name, u.id] }, prompt: 'Select user' },
        { attribute: :chat, type: :select, options: Chat.all.map { |c| [c.number, c.id] }, prompt: 'Select chat' },
        { attribute: :status, type: :select, options: Message.statuses.map do |k, v|
          [k.humanize, v]
        end, prompt: 'Select status' },
        { attribute: :archive_states, type: :select, options: { 'Active' => 'active', 'Archived' => 'archived' },
          prompt: 'Select Archive State' },
        { attribute: :created_from, type: :date_field, placeholder: 'Created From' },
        { attribute: :created_to, type: :date_field, placeholder: 'Created To' },
        { attribute: :archived_from, type: :date_field, placeholder: 'Archived From' },
        { attribute: :archived_to, type: :date_field, placeholder: 'Archived To' }
      ]
    }
  end
end
