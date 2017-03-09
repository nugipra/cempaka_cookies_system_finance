class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_commisions = NetworkCommision.sum(:commision)
    @total_wallet_balance = Member.sum(:wallet_balance)
  end
end
