class AddNestedSetColumnsToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :lft, :integer, null: false, index: true
    add_column :members, :rgt, :integer, null: false, index: true
    add_column :members, :network_depth, :integer, null: false, default: 0
    add_column :members, :children_count, :integer, null: false, default: 0
  end
end
