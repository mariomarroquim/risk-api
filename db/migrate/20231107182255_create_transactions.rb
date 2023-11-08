class CreateTransactions < ActiveRecord::Migration[7.1]
  def change
    create_table :transactions do |t|
      t.integer :transaction_id
      t.integer :merchant_id
      t.integer :user_id
      t.string :card_number
      t.datetime :transaction_date
      t.float :transaction_amount
      t.integer :device_id
      t.boolean :has_cbk
      t.timestamps
    end

    add_index :transactions, :transaction_id, unique: true
  end
end
