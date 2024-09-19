module Admin::UsersHelper
  def admin_users_table_settings
    head = [
      { name: 'Full Name', attribute: 'full_name', sortable: true, sort_column: 'full_name' },
      { name: 'Email', attribute: 'email', sortable: true, sort_column: 'email' },
      { name: 'Phone', attribute: 'phone', sortable: false },
      { name: 'Initiated Chats', sortable: false },
      { name: 'Received Chats', sortable: false },
      { name: 'Last Seen At', attribute: 'last_seen_at', sortable: true, sort_column: 'last_seen_at' },
      { name: 'Created At', attribute: 'created_at', sortable: true, sort_column: 'created_at' },
      { name: 'Archived At', attribute: 'discarded_at', sortable: true, sort_column: 'discarded_at' }
    ]

    body = [
      { call: lambda { |user|
        link_to user.full_name,
                admin_user_path(user),
                class: 'table-link'
      } },
      { attribute: :email },
      { call: lambda { |user|
        user.phone
      } },
      { call: lambda { |user|
        link_to user.initiated_chats.count,
                admin_chats_path(user_1: user.id),
                class: 'table-link'
      } },
      { call: lambda { |user|
        link_to user.received_chats.count,
                admin_chats_path(user_2: user.id),
                class: 'table-link'
      } },
      { call: lambda { |user|
        time_ago_in_words(user.last_seen_at) if user.last_seen_at
      } },
      { call: lambda { |user|
        user.created_at.strftime('%Y-%m-%d %H:%M')
      } },
      { call: lambda { |user|
        user.discarded_at&.strftime('%Y-%m-%d %H:%M')
      } }
    ]

    {
      models: @resource,
      data: @resources,
      head:,
      body:
    }
  end

  def admin_users_form_settings
    form_settings = {
      models: [:admin, @resource],
      show_path: @resource.persisted? ? admin_user_path(@resource) : admin_users_path,
      edit_path: @resource.persisted? ? edit_admin_user_path(@resource) : nil,
      fields: [
        {
          attribute: :email,
          type: :text_field,
          required: true
        },
        {
          attribute: :first_name,
          type: :text_field,
          required: true
        },
        {
          attribute: :last_name,
          type: :text_field,
          required: true
        },
        {
          attribute: :phone,
          type: :text_field
        }
      ]
    }

    if current_page?(new_admin_user_path)
      form_settings[:fields] << {
        attribute: :password,
        type: :text_field,
        value: nil
      }
    end

    if current_page?(new_admin_user_path) || @resource.persisted? && current_page?(edit_admin_user_path(@resource))
      form_settings[:fields] << {
        attribute: :image,
        type: :file_field
      }
    end

    form_settings
  end

  def admin_users_filter_settings
    {
      index_path: admin_users_path,
      fields: [
        { attribute: :query, type: :text_field, placeholder: 'Email or full name' },
        { attribute: :archive_states, type: :select,
          options: { 'All' => 'all', 'Active' => 'active', 'Archived' => 'archived' }, prompt: 'Select Archive State' },
        { attribute: :last_seen_from, type: :date_field, placeholder: 'Last seen From' },
        { attribute: :last_seen_to, type: :date_field, placeholder: 'Last seen To' },
        { attribute: :created_from, type: :date_field, placeholder: 'Created From' },
        { attribute: :created_to, type: :date_field, placeholder: 'Created To' },
        { attribute: :archived_from, type: :date_field, placeholder: 'Archived From' },
        { attribute: :archived_to, type: :date_field, placeholder: 'Archived To' }
      ]
    }
  end
end
