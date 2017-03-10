class Member < ApplicationRecord
  belongs_to :upline, class_name: "Member", required: false
  has_many :transactions
  has_many :network_commisions, class_name: "NetworkCommision", foreign_key: "member_id"
  has_many :wallet_transactions

  validates_presence_of :member_id, :fullname
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.email.present?}

  before_create :set_depth
  #before_update :update_network_commisions, if: Proc.new{|m| m.upline_id_changed?}
  after_create :generate_network_commisions

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

  def update_depth
    self.set_depth
    self.save
  end

  def get_network_fee_from_descendant(descendant)
    level_difference = descendant.network_depth - self.network_depth
    return NETWORK_LEVEL_FEE[level_difference - 1]
  end

  def total_network_commisions(options = {})
    self.network_commisions.where(options).sum(:commision)
  end

  #private
  def generate_network_commisions
    network_upline = self.upline

    levels = 1
    while levels <= 10 && network_upline.present?
      network_upline.network_commisions.create(
        descendant_id: self.id,
        commision: network_upline.get_network_fee_from_descendant(self)
      )

      network_upline = network_upline.upline
      levels += 1
    end
  end

  def generate_wallet_transactions_from_network_commisions
    self.network_commisions.each do |nc|
      nc.generate_wallet_transaction
    end
  end

  def wallet_balance=(val)
    raise "Forbidden method !"
  end

  private
  def update_network_commisions
    network_upline = Member.find(self.upline_id_was)

    while network_upline.present?
      NetworkCommision.where(
        member_id: network_upline.id,
        descendant_id: self.self_and_descendants.collect(&:id),
        paid: false
      ).destroy_all

      network_upline = network_upline.upline
    end

    self.self_and_descendants.each do |member|
      member.update_depth
      member.generate_network_commisions
    end
  end

end
