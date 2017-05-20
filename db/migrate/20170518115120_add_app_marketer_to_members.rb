class AddAppMarketerToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :app_marketer, :boolean, default: false
  end
end
