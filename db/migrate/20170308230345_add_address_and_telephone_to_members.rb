class AddAddressAndTelephoneToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :address, :text
    add_column :members, :telephone, :string
  end
end
