class Member < ApplicationRecord
  belongs_to :upline, class_name: "Member", required: false
  has_many :transactions
  has_many :network_commisions, class_name: "NetworkCommision", foreign_key: "member_id"
  has_many :wallet_transactions

  validates_presence_of :member_id, :fullname
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.email.present?}
  validate :should_not_update_member_id_for_core_member, on: :update

  before_create :set_depth
  #before_update :update_network_commisions, if: Proc.new{|m| m.upline_id_changed?}
  after_create :generate_network_commisions

  acts_as_nested_set parent_column: "upline_id"

  NETWORK_LEVEL_FEE = [5000, 1800, 1800, 1800, 1000, 1000, 1000, 300, 300, 300]
  NETWORK_LEVEL_LIMIT = 30280000

  COMPANY_MEMBER_ID = "DC03170000001" # dDanus Cempaka Cookies
  OWNER_MEMBER_ID   = "DC03170000002" # Andri Hidayatulloh / Kenni Santika
  WEB_DEV_MEMBER_ID = "DC03170000003" # Nugi Nugraha
  ADMIN_MEMBER_ID   = "DC03170000004" # Siti Nurjanah
  CORE_MEMBER_IDS   = [COMPANY_MEMBER_ID, OWNER_MEMBER_ID, WEB_DEV_MEMBER_ID, ADMIN_MEMBER_ID]

  def self.company
    Member.where(member_id: COMPANY_MEMBER_ID).first
  end

  def self.owner
    Member.where(member_id: OWNER_MEMBER_ID).first
  end

  def self.web_dev
    Member.where(member_id: WEB_DEV_MEMBER_ID).first
  end

  def self.admin
    Member.where(member_id: ADMIN_MEMBER_ID).first
  end

  def core_member?
    CORE_MEMBER_IDS.include?(self.member_id)
  end

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
    return if self.member_id == COMPANY_MEMBER_ID

    levels = 1
    while levels <= 10 && network_upline.present?
      if network_upline == Member.company && levels < 10
        company_commision = 0
        (levels..10).to_a.each  do |l|
          company_commision += NETWORK_LEVEL_FEE[l-1]
        end
        network_upline.network_commisions.create(
          descendant_id: self.id,
          commision: company_commision
        )
      else
        network_upline.network_commisions.create(
          descendant_id: self.id,
          commision: network_upline.get_network_fee_from_descendant(self)
        )
      end

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
  def should_not_update_member_id_for_core_member
    if self.member_id_changed? && CORE_MEMBER_IDS.include?(self.member_id_was)
      errors.add(:member_id, "can't be changed")
    end
  end

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
