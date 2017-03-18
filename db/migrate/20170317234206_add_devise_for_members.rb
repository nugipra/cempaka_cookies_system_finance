class AddDeviseForMembers < ActiveRecord::Migration[5.0]
  def change
    ## Database authenticatable
    add_column :members, :encrypted_password, :string, null: false, default: ""

    ## Rememberable
    add_column :members, :remember_created_at, :datetime 

    ## Trackable
    add_column :members, :sign_in_count, :integer, default: 0, null: false
    add_column :members, :current_sign_in_at, :datetime 
    add_column :members, :last_sign_in_at, :datetime
    add_column :members, :current_sign_in_ip, :string
    add_column :members, :last_sign_in_ip, :string

    ## Admin flag
    add_column :members, :the_admin, :boolean, default: false
  end
end
