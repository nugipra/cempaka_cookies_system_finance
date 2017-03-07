class Member < ApplicationRecord
  belongs_to :upline, class_name: "Member", required: false

  validates_presence_of :member_id
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.member_id.present?}

  def name_with_member_id
    fullname + " - " + member_id
  end
end
