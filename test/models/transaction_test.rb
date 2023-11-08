require 'test_helper'

class TransactionTest < ActiveSupport::TestCase
  setup do
    data = transactions(:sample).attributes
    data[:transaction_id] = 35_363_455
    data[:id] = nil

    @transaction = Transaction.new(data)
  end

  test 'should persist a valid transaction' do
    assert @transaction.save
  end

  test 'should set the has_cbk after creation' do
    assert @transaction.save
    assert_not @transaction.has_cbk.nil?
  end

  test 'should not persist an invalid transaction (without a required attribute)' do
    @transaction.transaction_id = nil

    assert_not @transaction.valid?
    assert @transaction.errors.include?(:transaction_id)
  end

  test 'should not persist an invalid transaction (with duplicated transaction ID)' do
    assert @transaction.save

    duplicated_transaction = Transaction.new(@transaction.attributes)

    assert_not duplicated_transaction.valid?
    assert duplicated_transaction.errors.include?(:transaction_id)
  end

  test 'should not persist an invalid transaction (with future transaction date)' do
    @transaction.transaction_date = Date.today + 10.days

    assert_not @transaction.valid?
    assert @transaction.errors.include?(:transaction_date)
  end

  test 'should not persist an invalid transaction (with zero amount)' do
    @transaction.transaction_amount = 0.0

    assert_not @transaction.valid?
    assert @transaction.errors.include?(:transaction_amount)
  end

  test 'should not persist an invalid transaction (with negative amount)' do
    @transaction.transaction_amount = -10.0

    assert_not @transaction.valid?
    assert @transaction.errors.include?(:transaction_amount)
  end
end
