class AddNetworkCommisionPaymentIdToNetworkCommisions < ActiveRecord::Migration[5.0]
  def change
    add_column :network_commisions, :network_commision_payment_id, :integer
  end
end
