require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload = transactions(:sample).attributes
    @payload[:transaction_id] = Kernel.rand(Time.current.to_i)
    @payload[:id] = nil
  end

  test 'should persist a valid transaction' do
    assert_difference('Transaction.count') do
      post transactions_url, params: @payload, as: :json
    end

    assert_response :created
  end

  test 'should not persist an invalid transaction' do
    @payload[:transaction_id] = nil

    assert_no_difference('Transaction.count') do
      post transactions_url, params: @payload, as: :json
    end

    assert_response :unprocessable_entity
  end

  test 'should reject an transaction if the previous transaction from the same user was charged back' do
    transaction = Transaction.new(@payload)
    transaction.has_cbk = true
    transaction.save!

    assert_no_difference('Transaction.count') do
      post transactions_url, params: @payload, as: :json
    end
  end

  test 'should reject an transaction if the expected number of transactions per month was exceeded' do
    (1..6).each do |month|
      @payload[:transaction_id] = Kernel.rand(Time.current.to_i)

      transaction = Transaction.new(@payload)
      transaction.created_at = month.months.ago.beginning_of_month
      transaction.save!
    end

    assert_no_difference('Transaction.count') do
      post transactions_url, params: @payload, as: :json
    end
  end

  test 'should reject an transaction if the expected amount of transactions per month was exceeded' do
    (1..6).each do |month|
      3.times do
        @payload[:transaction_id] = Kernel.rand(Time.current.to_i)

        transaction = Transaction.new(@payload)
        transaction.created_at = month.months.ago.beginning_of_month
        transaction.save!
      end
    end

    assert_no_difference('Transaction.count') do
      @payload[:transaction_amount] = 100.0
      post transactions_url, params: @payload, as: :json
    end
  end
end
