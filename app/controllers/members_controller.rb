class MembersController < ApplicationController
  before_action :authenticate_member!
  before_action :admin_or_region_admin_required, except: [
    :change_password, :update_password, :wallet_history, :network_commisions
  ]
  before_action :set_member, only: [
    :show, :edit, :update, :destroy, :network_commisions, :web_development_commisions,
    :add_registration_quota, :process_add_registration_quota
  ]

  # GET /members
  # GET /members.json
  def index
    @members = Member.where(
      current_member.the_admin? ? {} : {region_id: current_member.region_id}
    ).order("created_at").paginate(:page => params[:page], :per_page => 30)
  end

  # GET /members/1
  # GET /members/1.json
  def show
    if !current_member.the_admin? && current_member.region_id != @member.region_id
      redirect_to "/", notice: "Access denied"
      return
    end

    @network_commisions_limit = 10
    @network_commisions = @member.network_commisions.joins(:member).order("id desc").limit(@network_commisions_limit)
    @show_view_all_network_commisions = @member.network_commisions.count > @network_commisions_limit

    @total_network_commisions = @member.total_network_commisions
    @total_descendants = @member.descendants.count

    @transactions = @member.transactions.where(referral: false).order("id DESC")
    @referral_transactions = @member.transactions.where(referral: true).order("id DESC")
    @total_referral_commisions = @member.transactions.where(referral: true).sum(:referral_commision)

    if @member.web_dev?
      @latest_members_limit = 10
      @latest_members = Member.where.not(member_id: Member::CORE_MEMBER_IDS).order("id desc").limit(@latest_members_limit)
      @show_view_all_network_commisions = Member.where.not(member_id: Member::CORE_MEMBER_IDS).count > @latest_members_limit
      @total_web_dev_commisions = WalletTransaction.where(member_id: @member.id, transaction_type: "web development commision").sum(:amount)
    end
  end

  # GET /members/new
  def new
    if params[:upline_id].blank? || (params[:region] == "new" && !current_member.the_admin?)
      redirect_to members_path
      return
    end

    @upline = Member.find(params[:upline_id])
    if current_member.region_id != @upline.region_id
      redirect_to members_path
      return
    end

    if current_member.the_region_admin? && current_member.member_registration_quota.zero?
      redirect_to members_path, notice: "There is no registration quota left"
      return
    end

    @member = Member.new(upline_id: params[:upline_id])
    if params[:region] == "new" && current_member.the_admin?
      @member.set_region_admin = "1"
    end
    @uplines = Member.where(id: @member.upline_id)
  end

  # GET /members/1/edit
  def edit
    unless current_member.region_id == @member.region_id
      redirect_to "/", notice: "Access denied"
      return
    end

    @uplines = Member.where(id: @member.upline_id)
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)
    unless @member.set_region_admin == "1"
      @member.region_id = current_member.region_id
    end

    respond_to do |format|
      if @member.save
        format.html { redirect_to @member, notice: 'Member was successfully created.' }
        format.json { render :show, status: :created, location: @member }
      else
        @uplines = Member.order("fullname")
        format.html { render :new }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /members/1
  # PATCH/PUT /members/1.json
  def update
    respond_to do |format|
      if @member.update(member_params)
        format.html { redirect_to @member, notice: 'Member was successfully updated.' }
        format.json { render :show, status: :ok, location: @member }
      else
        @uplines = Member.where.not(id: @member.self_and_descendants.collect(&:id)).order("fullname")
        format.html { render :edit }
        format.json { render json: @member.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /members/1
  # DELETE /members/1.json
  def destroy
    if !current_member.the_admin?
      redirect_to "/", notice: "Access denied"
      return
    end

    @member.destroy unless @member.core_member?
    respond_to do |format|
      format.html { redirect_to members_url, notice: "Member was#{@member.core_member? ? ' not' : ''} successfully destroyed."}
      format.json { head :no_content }
    end
  end

  def add_registration_quota
    unless current_member.the_admin? || @member.the_region_member?
      redirect_to "/", notice: "Access denied"
      return
    end
  end

  def process_add_registration_quota
    unless current_member.the_admin? || @member.the_region_member?
      redirect_to "/", notice: "Access denied"
      return
    end

    updated_quota = @member.member_registration_quota + params[:total_quota_addition].to_i
    @member.update_column :member_registration_quota, updated_quota

    redirect_to @member, notice: 'Registration qouta was successfully added.'
  end

  def network_commisions
    if !current_member.the_admin? && current_member != @member
      redirect_to "/", notice: "Access denied"
      return
    end

    @network_commisions = @member.network_commisions.joins(:member).order("id desc").paginate(:page => params[:page], :per_page => 30)
    @total_network_commisions = @member.total_network_commisions
  end

  def web_development_commisions
    unless @member.web_dev?
      redirect_to @member
      return
    end

    @latest_members = Member.where.not(member_id: Member::CORE_MEMBER_IDS).order("id desc").paginate(:page => params[:page], :per_page => 30)
    @total_web_dev_commisions = WalletTransaction.where(member_id: @member.id, transaction_type: "web development commision").sum(:amount)
  end

  def change_password
    @member = current_member
  end

  def update_password
    @member = Member.find(current_member.id)
    if @member.update_with_password(member_password_params)
      # Sign in the member by passing validation in case their password changed
      bypass_sign_in(@member)
      notice = params[:member][:password].blank? ? "Password is not changed because you didn't enter new password" : "Password has succesfully updated"
      redirect_to change_password_member_path, notice: notice
    else
      render "change_password"
    end
  end

  def wallet_history
    @member = current_member
    @wallet_transactions = @member.wallet_transactions.includes(:remarks_object).order("created_at DESC, id DESC").paginate(:page => params[:page], :per_page => 15)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      attrs = [:member_id, :fullname, :email, :upline_id, :telephone, :address, :package]
      attrs += [:region_name, :set_region_admin] if current_member.the_admin?

      params.require(:member).permit(attrs)
    end

    def member_password_params
      params.require(:member).permit(:password, :password_confirmation, :current_password)
    end
end
