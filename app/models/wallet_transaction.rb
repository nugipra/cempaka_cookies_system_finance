class WalletTransaction < ApplicationRecord
  belongs_to :member

  validates :amount, :transaction_type, presence: true
  validates :amount, numericality: true, if: Proc.new{|wt| wt.amount.present?}
  validate :wallet_transaction_type_should_be_valid
  validate :updated_balance_should_not_be_negative, if: Proc.new{|wt| wt.amount.present?}

  before_create :adjust_amount, :update_balance 
  after_create :update_member_wallet_balance

  VALID_TRANSACTION_TYPES = ["network commision", "withdraw", "deposit", "referral commision"]

  private
    def wallet_transaction_type_should_be_valid
      unless VALID_TRANSACTION_TYPES.include?(self.transaction_type)
        errors.add(:transaction_type, "is invalid")
      end
    end

    def updated_balance_should_not_be_negative
      current_balance = member.wallet_balance
      if self.transaction_type == "withdraw"
        if self.amount > current_balance
          errors.add(:amount, "must be lower than #{current_balance} (insufficient fund)")
        end
      end
    end

    def update_balance
      self.balance = member.wallet_balance + self.amount
    end

    def adjust_amount
      if self.transaction_type == "withdraw"
        self.amount = -(self.amount)
      end
    end

    def update_member_wallet_balance
      member.update_column(:wallet_balance, member.wallet_balance + self.amount)
    end
end
