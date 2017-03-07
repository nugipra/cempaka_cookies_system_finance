class SearchController < ApplicationController
  before_action :authenticate_user!

  def index
    @q = Member.ransack(params[:q])
  end

  def results
    @q = Member.ransack(params[:q])
    @members = @q.result(distinct: true)
  end
end
