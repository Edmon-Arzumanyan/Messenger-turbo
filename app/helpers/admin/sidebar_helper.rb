module Admin::SidebarHelper
  def admin_sidebar_links
    links = []

    # Users link and its sublinks
    links << {
      title: 'Users',
      url: admin_users_path,
      icon: :groups,
      sublinks: [
        {
          title: 'Add New User',
          url: new_admin_user_path,
          icon: :person_add
        }
      ]
    }

    if @resource&.persisted? && @resource.is_a?(User)
      links.last[:sublinks] << {
        title: @resource.full_name,
        url: admin_user_path(@resource),
        icon: :person
      }
    end

    # Chats link and its sublinks
    links << {
      title: 'Chats',
      url: admin_chats_path,
      icon: :chat,
      sublinks: [
        {
          title: 'Add New Chat',
          url: new_admin_chat_path,
          icon: :note_add
        }
      ]
    }

    if @resource&.persisted? && @resource.is_a?(Chat)
      links.last[:sublinks] << {
        title: @resource.number,
        url: admin_chat_path(@resource),
        icon: :chat
      }
    end

    # Messages link and its sublinks
    links << {
      title: 'Messages',
      url: admin_messages_path,
      icon: :mail,
      sublinks: [
        {
          title: 'Add New Message',
          url: new_admin_message_path,
          icon: :note_add
        }
      ]
    }

    if @resource&.persisted? && @resource.is_a?(Message)
      links.last[:sublinks] << {
        title: 'Message Details',
        url: admin_message_path(@resource),
        icon: :mail
      }
    end

    links
  end
end
