class CreateTransactions < ActiveRecord::Migration[5.0]
  def change
    create_table :transactions do |t|
      t.references :member, foreign_key: true
      t.string :product_name
      t.integer :price
      t.integer :quantity
      t.text :note

      t.timestamps
    end
  end
end
