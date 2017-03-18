class HomeController < ApplicationController
  before_action :authenticate_member!

  def index
    if current_member.the_admin?
      @total_commisions = NetworkCommision.sum(:commision)
      @total_wallet_balance = Member.sum(:wallet_balance)
      @total_web_dev_commisions = WalletTransaction.where(transaction_type: "web development commision").sum(:amount)
    else
      @member = current_member
      @network_commisions_limit = 10
      @network_commisions = @member.network_commisions.joins(:member).order("id desc").limit(@network_commisions_limit)
      @show_view_all_network_commisions = @member.network_commisions.count > @network_commisions_limit

      @total_network_commisions = @member.total_network_commisions
      @total_descendants = @member.descendants.count

      @transactions = @member.transactions.where(referral: false).order("id DESC")
      @referral_transactions = @member.transactions.where(referral: true).order("id DESC")
      @total_referral_commisions = @member.transactions.where(referral: true).sum(:referral_commision)
    end
  end
end
