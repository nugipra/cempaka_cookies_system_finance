class NetworkCommision < ApplicationRecord
  belongs_to :member
  belongs_to :descendant, class_name: "Member"

  after_create :generate_wallet_transaction

  def generate_wallet_transaction
    WalletTransaction.create(
      member_id: self.member_id,
      amount: self.commision,
      remarks: "joined as new reseller",
      created_at: self.created_at,
      transaction_type: "network commision",
      remarks_object_id: self.descendant_id,
      remarks_object_type: "Member"
    )
  end
end
