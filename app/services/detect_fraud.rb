class DetectFraud
  TIME_FRAME_CBK_DETECTION_DAYS = 2
  TIME_FRAME_FRAUD_DETECTION_MONTHS = 6

  def self.call(*, &)
    new(*, &).call
  end

  def initialize(transaction)
    @transaction = transaction
  end

  # TODO: This block of code can be optimized. From suspicion (rule) precedence
  # to caching temporal results by merchant_id, user_id and card_number. Due to
  # algorithm explainability and lack of time, I did not fully optimise this.
  def call
    return if @transaction.blank?

    suspicions = [
      recent_chargeback?,
      number_of_transactions_exceeded_by?(merchant_id: @transaction.merchant_id),
      amount_of_transactions_exceeded_by?(merchant_id: @transaction.merchant_id),
      number_of_transactions_exceeded_by?(user_id: @transaction.user_id),
      amount_of_transactions_exceeded_by?(user_id: @transaction.user_id),
      number_of_transactions_exceeded_by?(card_number: @transaction.card_number),
      amount_of_transactions_exceeded_by?(card_number: @transaction.card_number)
    ]

    suspicious_transaction = suspicions.any?

    @transaction.update!(has_cbk: suspicious_transaction)

    !suspicious_transaction
  end

  def recent_chargeback?
    Transaction
      .where(created_at: TIME_FRAME_CBK_DETECTION_DAYS.days.ago.beginning_of_day..)
      .where(user_id: @transaction.user_id)
      .where.not(id: @transaction.id)
      .exists?(has_cbk: true)
  end

  def number_of_transactions_exceeded_by?(filter)
    transactions_qty_by_month = Transaction
                                .where(filter)
                                .where(created_at: TIME_FRAME_FRAUD_DETECTION_MONTHS.months.ago.beginning_of_month..)
                                .group_by_month(:created_at)
                                .count
                                .values

    mean_transactions_qty = transactions_qty_by_month.sum.to_f / transactions_qty_by_month.size

    transactions_qty_std_deviation = Math.sqrt(
      transactions_qty_by_month.map { |item| (item - mean_transactions_qty)**2 }.sum / transactions_qty_by_month.size
    )

    transaction_this_month = Transaction
                             .where(filter)
                             .where(created_at: Date.today.beginning_of_month..)
                             .count

    transaction_this_month >= (mean_transactions_qty + (3 * transactions_qty_std_deviation))
  end

  def amount_of_transactions_exceeded_by?(filter)
    amounts_by_month = Transaction
                       .where(filter)
                       .where(created_at: TIME_FRAME_FRAUD_DETECTION_MONTHS.months.ago.beginning_of_month..)
                       .group_by_month(:created_at)
                       .sum(:transaction_amount)
                       .values

    mean_amount = amounts_by_month.sum.to_f / amounts_by_month.size

    amount_std_deviation = Math.sqrt(
      amounts_by_month.map { |item| (item - mean_amount)**2 }.sum / amounts_by_month.size
    )

    amount_this_month = Transaction
                        .where(filter)
                        .where(created_at: Date.today.beginning_of_month..)
                        .sum(:transaction_amount)

    amount_this_month >= (mean_amount + (3 * amount_std_deviation))
  end
end
