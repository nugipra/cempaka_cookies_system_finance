class AddMemberRegistrationQuotaToMembers < ActiveRecord::Migration[5.0]
  def change
    add_column :members, :member_registration_quota, :integer, default: 0
  end
end
