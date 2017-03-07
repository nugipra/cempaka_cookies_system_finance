class Member < ApplicationRecord
  belongs_to :upline, class_name: "Member", required: false
  has_many :transactions

  validates_presence_of :member_id
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.email.present?}

  before_create :set_depth

  acts_as_nested_set parent_column: "upline_id"

  NETWORK_LEVEL_FEE = [5000, 1800, 1800, 1800, 1000, 1000, 1000, 300, 300, 300]
  NETWORK_LEVEL_LIMIT = 30280000

  def name_with_member_id
    fullname + " - " + member_id
  end

  def reseller_point
    self.transactions.sum(:total) * 0.2
  end

  def set_depth
    if self.upline.present?
      self.network_depth = self.upline.network_depth + 1
    else
      self.network_depth = 0
    end
  end

  def get_network_fee_from_descendant(descendant)
    level_difference = descendant.network_depth - self.network_depth
    return NETWORK_LEVEL_FEE[level_difference - 1]
  end

  def get_network_fee
    fee = self.descendants.collect{|d| self.get_network_fee_from_descendant(d)}.sum
    fee = NETWORK_LEVEL_LIMIT if fee >= NETWORK_LEVEL_LIMIT
    return fee
  end
end
