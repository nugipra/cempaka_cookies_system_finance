class MembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_member, only: [:show, :edit, :update, :destroy]

  # GET /members
  # GET /members.json
  def index
    @members = Member.order("created_at").paginate(:page => params[:page], :per_page => 30)
  end

  # GET /members/1
  # GET /members/1.json
  def show
    @network_commisions = @member.network_commisions.joins(:member).order("id desc")
    @total_network_commisions = @member.total_network_commisions
    @total_unpaid_network_commisions = @member.total_network_commisions(paid: false)
    @total_descendants = @member.descendants.count 
  end

  # GET /members/new
  def new
    @member = Member.new(upline_id: params[:upline_id])
    @uplines = Member.order("fullname")
  end

  # GET /members/1/edit
  def edit
    @uplines = Member.where.not(id: @member.self_and_descendants.collect(&:id)).order("fullname")
  end

  # POST /members
  # POST /members.json
  def create
    @member = Member.new(member_params)

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
    @member.destroy unless @member.core_member?
    respond_to do |format|
      format.html { redirect_to members_url, notice: "Member was#{@member.core_member? ? ' not' : ''} successfully destroyed."}
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def member_params
      params.require(:member).permit(:member_id, :fullname, :email, :upline_id, :telephone, :address)
    end
end
