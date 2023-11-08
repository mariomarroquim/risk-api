class TransactionsController < ApplicationController
  # TODO: Fix input/output accordingly to the specs
  def create
    @transaction = Transaction.new(transaction_params)

    if @transaction.save
      render json: @transaction, status: :created
    else
      render json: @transaction.errors, status: :unprocessable_entity
    end
  end

  def transaction_params
    params.require(:transaction).permit(
      :transaction_id,
      :merchant_id,
      :user_id,
      :card_number,
      :transaction_date,
      :transaction_amount,
      :device_id
    )
  end
end
