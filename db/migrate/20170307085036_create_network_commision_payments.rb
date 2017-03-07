class CreateNetworkCommisionPayments < ActiveRecord::Migration[5.0]
  def change
    create_table :network_commision_payments do |t|
      t.integer :total_payment
      t.string :payment_method
      t.references :member, foreign_key: true
      t.text :note

      t.timestamps
    end
  end
end
