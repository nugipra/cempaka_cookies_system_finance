class HomeController < ApplicationController
  before_action :authenticate_user!

  def index
    @total_commisions = NetworkCommision.sum(:commision)
    @total_paid_commisions = NetworkCommision.where(paid: true).sum(:commision)
    @total_unpaid_commisions = NetworkCommision.where(paid: false).sum(:commision)
  end
end
