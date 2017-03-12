class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_commisions = NetworkCommision.sum(:commision)
    @total_wallet_balance = Member.sum(:wallet_balance)
    @total_web_dev_commisions = WalletTransaction.where(transaction_type: "web development commision").sum(:amount)
  end
end
