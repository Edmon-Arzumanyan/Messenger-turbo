class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :chat, null: false, foreign_key: true
      t.text :body, null: false
      t.integer :status, default: 0
      t.boolean :is_edited, default: false, null: false

      t.timestamps
    end
  end
end
