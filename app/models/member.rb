class Member < ApplicationRecord
  validates_presence_of :member_id
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.member_id.present?}
end
