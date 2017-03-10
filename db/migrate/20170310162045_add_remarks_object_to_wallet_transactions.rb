class AddRemarksObjectToWalletTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :wallet_transactions, :remarks_object_id, :integer
    add_column :wallet_transactions, :remarks_object_type, :string
  end
end
