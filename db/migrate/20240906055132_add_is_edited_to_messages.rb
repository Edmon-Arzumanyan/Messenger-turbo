class AddIsEditedToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :is_edited, :boolean, default: false
  end
end
