class TransactionsController < ApplicationController
  def create
    @transaction = Transaction.new(transaction_params)

    result = { transaction_id: @transaction.transaction_id }

    if @transaction.save && !DetectFraud.call(@transaction)
      render json: result.merge(recommendation: 'approve'), status: :created
    else
      # TODO: Use a more sofisticated service object approach to better express
      # different outputs via more informative HTTP status codes.
      render json: result.merge(recommendation: 'deny'), status: :unprocessable_entity
    end
  end

  def transaction_params
    params.permit(
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
