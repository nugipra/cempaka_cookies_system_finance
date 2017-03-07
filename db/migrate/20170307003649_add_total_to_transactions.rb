class AddTotalToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :total, :integer
  end
end
