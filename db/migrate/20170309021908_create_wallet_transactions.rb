class CreateWalletTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :wallet_transactions do |t|
      t.references :member, foreign_key: true
      t.text :remarks
      t.integer :amount
      t.integer :balance

      t.timestamps
    end

    add_column :members, :wallet_balance, :integer, default: 0
  end
end
