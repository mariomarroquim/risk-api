class DetectFraud
  TIME_FRAME_CBK_DETECTION_DAYS = 2
  TIME_FRAME_FRAUD_DETECTION_MONTHS = 6

  def self.call(*, &)
    new(*, &).call
  end

  def initialize(transaction)
    @transaction = transaction
  end

  def call
    return false if @transaction.blank?

    suspections = [chargeback_before?]

    suspections << number_of_transactions_exceeded_by?(merchant_id: @transaction.merchant_id)
    suspections << amount_of_transactions_exceeded_by?(merchant_id: @transaction.merchant_id)

    suspections << number_of_transactions_exceeded_by?(user_id: @transaction.user_id)
    suspections << amount_of_transactions_exceeded_by?(user_id: @transaction.user_id)

    suspections << number_of_transactions_exceeded_by?(card_number: @transaction.card_number)
    suspections << amount_of_transactions_exceeded_by?(card_number: @transaction.card_number)

    suspicious_transaction = suspections.any?(true)

    @transaction.update!(has_cbk: suspicious_transaction)

    !suspicious_transaction
  end

  def chargeback_before?
    Transaction.where(user_id: @transaction.user_id).last&.has_cbk?
  end

  def number_of_transactions_exceeded_by?(filter)
    transactions_by_month = Transaction
                            .where(filter)
                            .where(created_at: TIME_FRAME_FRAUD_DETECTION_MONTHS.months.ago.beginning_of_month..)
                            .group_by_month(:created_at)
                            .count
                            .values

    return false if transactions_by_month.blank?

    transaction_statistics = DescriptiveStatistics::Stats.new(transactions_by_month)
    mean_transactions_by_month = transaction_statistics.mean || 1.0
    std_deviation_transactions_by_month = transaction_statistics.standard_deviation || 0.0

    transactions_this_month = Transaction
                              .where(filter)
                              .where(created_at: Date.today.beginning_of_month..)
                              .count

    transactions_this_month >= (mean_transactions_by_month + (3 * std_deviation_transactions_by_month))
  end

  def amount_of_transactions_exceeded_by?(filter)
    transactions_by_month = Transaction
                            .where(filter)
                            .where(created_at: TIME_FRAME_FRAUD_DETECTION_MONTHS.months.ago.beginning_of_month..)
                            .group_by_month(:created_at)
                            .sum(:transaction_amount)
                            .values

    return false if transactions_by_month.blank?

    transaction_statistics = DescriptiveStatistics::Stats.new(transactions_by_month)
    mean_transactions_by_month = transaction_statistics.mean || 1.0
    std_deviation_transactions_by_month = transaction_statistics.standard_deviation || 0.0

    transactions_this_month = Transaction
                              .where(filter)
                              .where(created_at: Date.today.beginning_of_month..)
                              .count

    transactions_this_month >= (mean_transactions_by_month + (3 * std_deviation_transactions_by_month))
  end
end
