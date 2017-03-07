class CreateNetworkCommisions < ActiveRecord::Migration[5.0]
  def change
    create_table :network_commisions do |t|
      t.references :member, foreign_key: true
      t.references :descendant
      t.integer :commision
      t.boolean :paid, default: false

      t.timestamps
    end
  end
end
