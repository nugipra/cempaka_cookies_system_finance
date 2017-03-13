class AddReferralToTransactions < ActiveRecord::Migration[5.0]
  def change
    add_column :transactions, :referral, :boolean, default: false
    add_column :transactions, :referral_commision, :integer, default: 0
  end
end
