class NetworkCommisionPaymentsController < ApplicationController
  before_action :authenticate_user!

  def index
    @network_commision_payments = NetworkCommisionPayment.order("created_at desc").includes(:member)
  end

  def new
    if params[:member_id].blank?
      redirect_to network_commision_payments_path
      return
    end

    @member = Member.find(params[:member_id])
    @network_commisions = @member.network_commisions.joins(:member).where(paid: false).order("created_at desc")
    @total_unpaid_commissions = @member.total_network_commisions(paid: false)

    if @total_unpaid_commissions.zero?
      redirect_to member_path(@member)
      return
    end

    @network_commision_payment = NetworkCommisionPayment.new
    @network_commision_payment.member_id = @member.id
    @network_commision_payment.total_payment = @total_unpaid_commissions
  end

  def create
    @network_commission_payment = NetworkCommisionPayment.new(network_commission_payment_params)
    @member = @network_commission_payment.member
    @unpaid_network_commisions = @member.network_commisions.where(paid: false)
    @total_unpaid_commissions = @unpaid_network_commisions.sum(:commision)

    if @network_commission_payment.total_payment == @total_unpaid_commissions
      if @network_commission_payment.save
        @unpaid_network_commisions.each do |commision|
          commision.paid = true
          commision.network_commision_payment_id = @network_commission_payment.id
          commision.save
        end

        redirect_to params[:from].present? ? params[:from] : member_path(@member), notice: 'Unpaid network commisions was successfully processed.'
      else
        @network_commisions = @member.network_commisions.joins(:member).where(paid: false).order("created_at desc")
        render :new
      end
    else
      redirect_to new_network_commission_payment_path(member_id: @member.id), notice: 'Network commisions was updated during processing payment. Please try to process it once again.'
    end
  end

  def show
    @network_commission_payment = NetworkCommisionPayment.find(params[:id])
    @network_commisions = @network_commission_payment.network_commisions
    @member = @network_commission_payment.member
  end

  private
    # Never trust parameters from the scary internet, only allow the white list through.
    def network_commission_payment_params
      params.require(:network_commision_payment).permit(:member_id, :payment_method, :total_payment, :note)
    end
end
