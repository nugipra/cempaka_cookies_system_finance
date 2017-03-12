class AddPackageToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :package, :string, default: "silver"
  end
end
