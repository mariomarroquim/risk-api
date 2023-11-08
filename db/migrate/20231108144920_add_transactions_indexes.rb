class AddTransactionsIndexes < ActiveRecord::Migration[7.1]
  def change
    add_index :transactions, :merchant_id
    add_index :transactions, :user_id
    add_index :transactions, :card_number
    add_index :transactions, :created_at
  end
end
