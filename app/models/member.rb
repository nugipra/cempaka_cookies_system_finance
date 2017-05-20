class Member < ApplicationRecord
  devise :database_authenticatable, :rememberable, :trackable, :validatable

  belongs_to :upline, class_name: "Member", required: false
  has_many :transactions
  has_many :network_commisions, class_name: "NetworkCommision", foreign_key: "member_id"
  has_many :wallet_transactions
  belongs_to :region, required: false

  validates_presence_of :member_id, :fullname
  validates_presence_of :upline_id, unless: Proc.new{|m| m.member_id == COMPANY_MEMBER_ID}
  validates_uniqueness_of :member_id, if: Proc.new{|m| m.member_id.present?}
  validates_uniqueness_of :email, if: Proc.new{|m| m.email.present?}
  validate :should_not_update_member_id_for_core_member, on: :update
  validate :should_validate_registration_quota, on: :create
  validate :should_validate_region, if:  Proc.new{|m| m.set_region_admin == "1"}
  validates_presence_of :package, unless: Proc.new{|m| m.core_member?}
  validates_presence_of :email, if:  Proc.new{|m| m.set_region_admin == "1"}

  before_create :set_depth
  before_save :create_region_for_admin, if: Proc.new{|m| m.set_region_admin == "1"}
  #before_update :update_network_commisions, if: Proc.new{|m| m.upline_id_changed?}
  after_create :generate_network_commisions
  after_create :generate_wallet_transaction_from_web_dev_commision
  after_create :decrease_registration_quota
  before_save :set_initial_password, if: :need_to_set_initial_password?
  before_save :determine_app_marketer

  acts_as_nested_set parent_column: "upline_id"

  attr_accessor :set_region_admin
  attr_accessor :region_name

  NETWORK_LEVEL_FEE =        [5000, 1800, 1800, 1800, 1000, 1000, 1000, 300, 300, 300]
  NETWORK_LEVEL_FEE_REGION = [7000, 2500, 2500, 2500, 1200, 1200, 1200, 600, 600, 600]
  NETWORK_LEVEL_LIMIT = 30280000

  COMPANY_MEMBER_ID = "DC03170000001" # dDanus Cempaka Cookies
  OWNER_MEMBER_ID   = "DC03170000002" # Andri Hidayatulloh / Kenni Santika
  WEB_DEV_MEMBER_ID = "DC03170000003" # Nugi Nugraha
  ADMIN_MEMBER_ID   = "DC03170000004" # Siti Nurjanah
  CORE_MEMBER_IDS   = [COMPANY_MEMBER_ID, OWNER_MEMBER_ID, WEB_DEV_MEMBER_ID, ADMIN_MEMBER_ID]

  WEB_DEV_COMMISION = {bronze: 2000, silver: 1375, retail: 1375}

  after_destroy :remove_commisions_from_destroyed_user

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

  def company?
    COMPANY_MEMBER_ID == self.member_id
  end

  def web_dev?
    WEB_DEV_MEMBER_ID == self.member_id
  end

  def web_dev_commision
    Member::WEB_DEV_COMMISION[self.package.to_sym]
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
    fees = self.the_region_admin? ? NETWORK_LEVEL_FEE_REGION : NETWORK_LEVEL_FEE
    return fees[level_difference - 1]
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
      if network_upline == Member.company
        commision = (levels..10).to_a.collect{|l| NETWORK_LEVEL_FEE[l-1]}.sum
        commision = commision * 0.1 if self.app_marketer

        network_upline.network_commisions.create(
          descendant_id: self.id,
          commision: commision
        )
      else
        commision = network_upline.get_network_fee_from_descendant(self)
        commision = commision * 0.1 if self.app_marketer

        network_upline.network_commisions.create(
          descendant_id: self.id,
          commision: commision
        )
      end

      network_upline = network_upline.upline
      levels += 1
    end
  end

  def generate_wallet_transaction_from_web_dev_commision
    unless self.core_member?
      WalletTransaction.create(
        member_id: Member.web_dev.id,
        amount: Member::WEB_DEV_COMMISION[self.package.to_sym],
        remarks: "joined as new reseller (#{self.package} package)",
        created_at: self.created_at,
        transaction_type: "web development commision",
        remarks_object_id: self.id,
        remarks_object_type: "Member"
      )
    end
  end

  def generate_wallet_transactions_from_network_commisions
    self.network_commisions.order("created_at, id").each do |nc|
      nc.generate_wallet_transaction
    end
  end

  def wallet_balance=(val)
    raise "Forbidden method !"
  end

  def password_blank?
    self.encrypted_password.blank?
  end

  def password_required?
    # Password is required if it is being set, but not for new records
    if !persisted?
      false
    else
      !password.nil? || !password_confirmation.nil?
    end
  end

  def email_required?
    false
  end

  def need_to_set_initial_password?
    if self.password_blank?
      return self.email_changed? && self.email.present?
    elsif self.member_id_changed?
      return self.valid_password?(self.member_id_was)
    else
      return false
    end
  end

  def has_children?
    self.rgt - self.lft != 1
  end

  private

  def create_region_for_admin
    unless self.the_region_admin?
      region = Region.create(:name => self.region_name.strip)
      unless self.new_record?
        self.descendants.where(region_id: self.region_id).update_all(region_id: region.id)
      end

      self.region_id = region.id
      self.the_region_admin = true     
    end
  end

  def remove_commisions_from_destroyed_user
    # remove web dev commisions
    web_dev = Member.web_dev
    wt = WalletTransaction.where(
      member_id: web_dev .id,
      transaction_type: "web development commision",
      remarks_object_id: self.id,
      remarks_object_type: "Member"
    ).first.destroy

    last_transaction = web_dev.wallet_transactions.where("created_at < ?", wt.created_at).order("created_at desc, id desc").first
    last_wallet = last_transaction ? last_transaction.balance : 0
    web_dev.wallet_transactions.where("created_at >= ?", wt.created_at).order("created_at asc, id asc").each do |m|
      m.balance = m.amount + last_wallet
      m.save
      last_wallet = m.balance
    end
    web_dev.update_column :wallet_balance, last_wallet

    # remove network commisions
    removed_commisions = NetworkCommision.where(descendant_id: self.id).destroy_all
    removed_commisions.each do |rc|
      member = rc.member
      last_transaction = member.wallet_transactions.where("created_at < ?", rc.created_at).order("created_at desc, id desc").first
      last_wallet = last_transaction ? last_transaction.balance : 0
      member.wallet_transactions.where("created_at >= ?", rc.created_at).order("created_at asc, id asc").each do |m|
        m.balance = m.amount + last_wallet
        m.save
        last_wallet = m.balance
      end
      member.update_column :wallet_balance, last_wallet
    end
  end

  def should_not_update_member_id_for_core_member
    if self.member_id_changed? && CORE_MEMBER_IDS.include?(self.member_id_was)
      errors.add(:member_id, "can't be changed")
    end
  end

  def should_validate_region
    if self.region_name.blank?
      errors.add(:region_name, "can't be empty")
    elsif Region.where(name: self.region_name.strip).count > 0
      errors.add(:region_name, "has already been taken")
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

  def set_initial_password
    self.password = self.member_id
    self.password_confirmation = self.member_id
  end

  def should_validate_registration_quota
    unless self.core_member?
      region_admin = Member.where(the_region_admin: true, region_id: self.region_id).first
      if region_admin && region_admin.member_registration_quota.zero?
        errors.add(:member_registration_quota, "is empty")
      end
    end
  end

  def decrease_registration_quota
    unless self.core_member?
      region_admin = Member.where(the_region_admin: true, region_id: self.region_id).first
      if region_admin && self != region_admin
        updated_quota = region_admin.member_registration_quota - 1
        region_admin.update_column :member_registration_quota, updated_quota
      end
    end
  end

  def determine_app_marketer
    unless self.core_member?
      self.app_marketer = true if self.upline && self.upline.app_marketer?
    end
  end

end
