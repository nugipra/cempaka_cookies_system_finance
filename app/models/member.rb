class Member < ApplicationRecord
  validates_uniqueness_of :member_id
end
