class NetworkCommision < ApplicationRecord
  belongs_to :member
  belongs_to :descendant, class_name: "Member"

  after_create :generate_wallet_transaction
  after_destroy :remove_wallet_transaction

  def wallet_transaction_data
    {
	   member_id: self.member_id,
	   amount: self.commision,
	   remarks: "joined as new #{self.member.app_marketer? ? 'app marketer' : 'reseller'}",
	   created_at: self.created_at,
	   transaction_type: "network commision",
	   remarks_object_id: self.descendant_id,
	   remarks_object_type: "Member"
    }
  end

  def generate_wallet_transaction
    WalletTransaction.create(self.wallet_transaction_data)
  end

  def remove_wallet_transaction
    WalletTransaction.where(self.wallet_transaction_data).first.destroy
  end
end
