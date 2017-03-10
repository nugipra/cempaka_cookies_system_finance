class Transaction < ApplicationRecord
  belongs_to :member

  validates_presence_of :product_name, :quantity, :price
  validate :wallet_balance, if: Proc.new{|t| t.payment_type == "wallet"}

  before_save :update_total
  after_create :generate_wallet_transaction, if: Proc.new{|t| t.payment_type == "wallet"}

  def update_total
    self.total = self.quantity * self.price
  end

  def quantity_with_name
    "#{self.quantity} pcs #{self.product_name}"
  end

  private
    def wallet_balance
      current_balance = member.wallet_balance
      if current_balance < (self.quantity * self.price)
        errors.add(:payment_type, "is invalid : insufficient wallet balance (#{current_balance})")
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
end
