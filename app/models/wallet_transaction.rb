class WalletTransaction < ApplicationRecord
  belongs_to :member

  validates :remarks, :amount, presence: true
  validates :amount, numericality: true
  validate :updated_balance_should_not_be_negative

  before_create :update_balance
  after_create :update_member_wallet_balance

  private
    def updated_balance_should_not_be_negative
      current_balance = member.wallet_balance
      if member.wallet_balance + self.amount < 0
        errors.add(:amount, "must be greater than -#{current_balance}")
      end
    end

    def update_balance
      self.balance = member.wallet_balance + self.amount
    end

    def update_member_wallet_balance
      member.update_column(:wallet_balance, member.wallet_balance + self.amount)
    end
end
