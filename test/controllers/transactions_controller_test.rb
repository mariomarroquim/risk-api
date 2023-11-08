require 'test_helper'

class TransactionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @params = transactions(:sample).attributes
    @params[:transaction_id] = Kernel.rand(Time.current.to_i)
    @params[:id] = nil
  end

  test 'should persist a valid transaction and yield an approval' do
    assert_changes('Transaction.count', 1) do
      post transactions_url, params: @params, as: :json
    end

    assert_response :created

    expected_json = {
      'transaction_id' => @params[:transaction_id],
      'recommendation' => 'approve'
    }

    assert_equal expected_json, JSON.parse(response.body)
  end

  test 'should not persist an invalid transaction and yield a denial' do
    @params[:transaction_id] = nil

    assert_no_changes('Transaction.count') do
      post transactions_url, params: @params, as: :json
    end

    assert_response :unprocessable_entity

    expected_json = {
      'transaction_id' => @params[:transaction_id],
      'recommendation' => 'deny'
    }

    assert_equal expected_json, JSON.parse(response.body)
  end

  test 'should persist an transaction and deny it if a recent one from the same user was charged back' do
    @params[:transaction_id] = Kernel.rand(Time.current.to_i)

    assert_changes('Transaction.count', 1) do
      Transaction.create!(@params.merge(has_cbk: true))
      post transactions_url, params: @params, as: :json
    end

    assert_response :unprocessable_entity

    expected_json = {
      'transaction_id' => @params[:transaction_id],
      'recommendation' => 'deny'
    }

    assert_equal expected_json, JSON.parse(response.body)
  end

  test 'should persist an transaction and deny it if the expected number of transactions per month was exceeded' do
    assert_changes('Transaction.count', 1) do
      (1..6).each do |month_number|
        @params[:transaction_id] = Kernel.rand(Time.current.to_i)
        Transaction.create!(@params.merge(created_at: month_number.months.ago.beginning_of_month))
      end

      @params[:transaction_id] = Kernel.rand(Time.current.to_i)

      post transactions_url, params: @params, as: :json
    end

    assert_response :unprocessable_entity

    expected_json = {
      'transaction_id' => @params[:transaction_id],
      'recommendation' => 'deny'
    }

    assert_equal expected_json, JSON.parse(response.body)
  end

  test 'should persist an transaction and deny it if the expected total amount of transactions per month was exceeded' do
    assert_changes('Transaction.count', 1) do
      (1..6).each do |month|
        3.times do
          @params[:transaction_id] = Kernel.rand(Time.current.to_i)
          Transaction.create!(@params.merge(created_at: month.months.ago.beginning_of_month))
        end
      end

      @params[:transaction_id] = Kernel.rand(Time.current.to_i)
      @params[:transaction_amount] = 100.0

      post transactions_url, params: @params, as: :json
    end

    assert_response :unprocessable_entity

    expected_json = {
      'transaction_id' => @params[:transaction_id],
      'recommendation' => 'deny'
    }
  end
end
