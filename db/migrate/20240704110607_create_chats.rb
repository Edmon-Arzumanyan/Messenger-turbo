class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.references :user_1, null: false, foreign_key: { to_table: :users }
      t.references :user_2, null: false, foreign_key: { to_table: :users }
      t.string :number, index: { unique: true }, null: false

      t.datetime :discarded_at, index: true
      t.datetime :last_discarded_at, index: true
      t.timestamps
    end
  end
end
