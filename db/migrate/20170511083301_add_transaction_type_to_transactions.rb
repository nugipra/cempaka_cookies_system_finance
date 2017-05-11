class AddTransactionTypeToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :transaction_type, :string, :default => "retail"
  end
end
