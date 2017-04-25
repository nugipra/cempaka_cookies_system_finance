class SearchController < ApplicationController
  before_action :authenticate_member!
  before_action :admin_or_region_admin_required

  def index
    @q = Member.ransack(params[:q])
  end

  def results
    @q = Member.where(
      current_member.the_admin? ? {} : {region_id: current_member.region_id}
    ).ransack(params[:q])
    @members = @q.result(distinct: true).paginate(:page => params[:page], :per_page => 20)
  end
end
