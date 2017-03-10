class NetworkCommision < ApplicationRecord
  belongs_to :member
  belongs_to :descendant, class_name: "Member"

  after_create :generate_network_commision

  def generate_wallet_transaction
    member.wallet_transactions.create(
      amount: self.commision,
      remarks: "#{self.descendant.fullname} joined as new reseller",
      created_at: self.created_at,
      transaction_type: "network commision"
    )
  end
end
