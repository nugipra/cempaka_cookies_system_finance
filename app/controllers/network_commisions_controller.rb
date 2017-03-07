class NetworkCommisionsController < ApplicationController
  before_action :authenticate_user!

  def unpaid
    @total_unpaid_commisions = NetworkCommision.where(paid: false).sum(:commision)
    @members = Member.where("ID IN (SELECT member_id FROM network_commisions WHERE paid = ?)", false)
  end
end
