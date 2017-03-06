class CreateMembers < ActiveRecord::Migration[5.0]
  def change
    create_table :members do |t|
      t.string :member_id
      t.string :fullname
      t.string :email
      t.integer :upline_id

      t.timestamps
    end
  end
end
