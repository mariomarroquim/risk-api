require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @payload = transactions(:sample).attributes
    @payload[:transaction_id] = 35_363_455
  end

  test 'should persist a valid transaction' do
    assert_difference('Transaction.count') do
      post transactions_url, params: { transaction: @payload }, as: :json
    end

    assert_response :created
  end

  test 'should not persist an invalid transaction' do
    @payload[:transaction_id] = nil

    assert_no_difference('Transaction.count') do
      post transactions_url, params: { transaction: @payload }, as: :json
    end

    assert_response :unprocessable_entity
  end
end
