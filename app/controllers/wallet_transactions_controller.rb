class WalletTransactionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_member
  before_action :authenticate_wallet_session, except: [:verify, :do_verify]

  def index
    @wallet_transactions = @member.wallet_transactions.order("id DESC").paginate(:page => params[:page], :per_page => 15)
  end

  def new
    unless ["deposit", "withdraw"].include?(params[:type])
      redirect_to wallet_transactions_path(@member)
      return
    end
    @wallet_transaction = WalletTransaction.new
  end

  def create
    @wallet_transaction = @member.wallet_transactions.new(wallet_transactions_params)

    respond_to do |format|
      if @wallet_transaction.valid?
        updated_remarks = "#{params[:transaction_type].downcase}"
        if @wallet_transaction.remarks.present?
          updated_remarks += " / #{@wallet_transaction.remarks}"
        end

        @wallet_transaction.remarks = updated_remarks
        @wallet_transaction.save

        notice_msg = (params[:type] == "withdraw" ? "Withdrawal" : "Deposit") + " fund success!"
        format.html { redirect_to wallet_transactions_path(@member), notice: notice_msg}
        format.json { render :show, status: :created, location: @wallet_transaction }
      else
        format.html { render :new }
        format.json { render json: @wallet_transaction.errors, status: :unprocessable_entity }
      end
    end
  end

  def verify
    if wallet_session_valid?
      flash[:notice] = nil
      redirect_to wallet_transactions_path(@member)
      return
    end
  end

  def do_verify
    if current_user.valid_password?(params[:user][:password])
      session[:accessing_wallet_time] = Time.now.to_i
      redirect_to wallet_transactions_path(@member)
    else
      redirect_to verify_wallet_transactions_path(@member), notice: 'Invalid password.'
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_member
      @member = Member.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def wallet_transactions_params
      params.require(:wallet_transaction).permit(:amount, :transaction_type, :remarks)
    end

    def authenticate_wallet_session
      unless wallet_session_valid?
        redirect_to verify_wallet_transactions_path(@member)
        return
      else
        session[:accessing_wallet_time] = Time.now.to_i
      end
    end

    def wallet_session_valid?
      return session[:accessing_wallet_time].present? && (Time.now.to_i - session[:accessing_wallet_time]) <= 300
    end
end