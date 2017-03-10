class AddPaymentTypeToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :payment_type, :string, default: "cash"
  end
end
