# frozen_string_literal: true

class AddFieldsToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :role, :integer, default: 0
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :last_seen_at, :datetime
    add_column :users, :discarded_at, :datetime
    add_index :users, :discarded_at
  end
end
