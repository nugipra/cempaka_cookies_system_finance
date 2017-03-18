class SearchController < ApplicationController
  before_action :authenticate_member!
  before_action :admin_required

  def index
    @q = Member.ransack(params[:q])
  end

  def results
    @q = Member.ransack(params[:q])
    @members = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 20)
  end
end
