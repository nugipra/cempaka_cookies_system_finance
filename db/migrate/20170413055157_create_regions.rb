class CreateRegions < ActiveRecord::Migration[5.0]
  def change
    create_table :regions do |t|
      t.string :name

      t.timestamps
    end
    add_column :members, :region_id, :integer
    add_column :members, :the_region_admin, :boolean, default: false

    default_region = Region.create(:name => "Bandung")
    Member.update_all(region_id: default_region.id)
  end
end
