class AccountsController < ApplicationController
  before_action :set_account
  before_action :authorize_account

  def balance
    render json: { balance: @account.balance.to_s }, status: :ok
  end

  def deposit
    amount = params[:amount].to_d

    if amount <= 0
      return render json: { error: "Amount must be positive" }, status: :unprocessable_content
    end

    @account.increment!(:balance, amount)

    render json: {
      message: "Deposit successful",
      balance: @account.balance.to_s
    }, status: :ok
  end

  private

  def set_account
    @account = Account.find_by(id: params[:id])
    if @account.nil?
      render json: { error: "Account not found" }, status: :not_found and return
    end
  end

  def authorize_account
    if @account && @account.user_id != @current_user.id
      render json: { error: "Forbidden" }, status: :forbidden and return
    end
  end
end
