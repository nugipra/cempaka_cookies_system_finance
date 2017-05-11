class Transaction < ApplicationRecord
  belongs_to :member

  validates_presence_of :product_name, :quantity, :price
  validate :wallet_balance, if: Proc.new{|t| t.payment_type == "wallet"}
  validate :referral_transaction

  before_save :update_total
  after_create :generate_wallet_transaction, if: Proc.new{|t| t.payment_type == "wallet"}
  after_create :generate_referral_commision, if: Proc.new{|t| t.referral}
  after_create :generate_product_commision

  REFERRAL_COMMISION = {referrer: 5000, web_dev: 2500}
  PRODUCT_COMMISION = {retail: 500, package: 1000}

  def update_total
    self.total = self.quantity * self.price
  end

  def quantity_with_name
    "#{self.quantity} pcs #{self.product_name}"
  end

  private
    def wallet_balance
      if self.quantity.present? && self.price.present?
        current_balance = member.wallet_balance
        if current_balance < (self.quantity * self.price)
          errors.add(:payment_type, "is invalid : insufficient wallet balance (#{current_balance})")
        end
      end
    end

    def referral_transaction
      if self.referral && self.payment_type == "wallet"
        errors.add(:referral, "transaction can't be paid through wallet")
      end
    end

    def generate_wallet_transaction
      WalletTransaction.create(
        member_id: self.member_id,
        amount: -self.total,
        remarks: self.quantity_with_name,
        created_at: self.created_at,
        transaction_type: "transaction payment",
        remarks_object_id: self.id,
        remarks_object_type: "Transaction"
      )
    end

    def generate_referral_commision
      total_commision_for_referrer = Transaction::REFERRAL_COMMISION[:referrer] * self.quantity
      self.update_column :referral_commision, total_commision_for_referrer

      # for referrer
      WalletTransaction.create(
        member_id: self.member_id,
        amount: total_commision_for_referrer,
        remarks: self.quantity_with_name,
        created_at: self.created_at,
        transaction_type: "referral commision",
        remarks_object_id: self.id,
        remarks_object_type: "Transaction"
      )

      # for web dev
      WalletTransaction.create(
        member_id: Member.web_dev.id,
        amount: Transaction::REFERRAL_COMMISION[:web_dev]* self.quantity,
        remarks: self.quantity_with_name,
        created_at: self.created_at,
        transaction_type: "web development commision",
        remarks_object_id: self.id,
        remarks_object_type: "Transaction"
      )
    end

    def generate_product_commision
      commission = Transaction::PRODUCT_COMMISION[self.transaction_type.to_sym] * self.quantity
      upline = self.member.upline

      if upline
        WalletTransaction.create(
          member_id: upline.id,
          amount: commission,
          remarks: "#{self.quantity_with_name} from #{self.member.fullname}",
          created_at: self.created_at,
          transaction_type: "product commision",
          remarks_object_id: self.id,
          remarks_object_type: "Transaction"
        )
      end
    end
end
