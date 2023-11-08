class Transaction < ApplicationRecord
  validates :transaction_id,
            :merchant_id,
            :user_id,
            :card_number,
            :transaction_date,
            :transaction_amount,
            :device_id,
            presence: true

  validates :transaction_id, uniqueness: true, allow_blank: true
  validates :transaction_date, comparison: { less_than_or_equal_to: Time.current }, allow_blank: true
  validates :transaction_amount, comparison: { greater_than: 0.0 }, allow_blank: true

  before_create :set_has_cbk

  private

  # TODO: Add proper implementation
  def set_has_cbk
    return unless has_cbk.nil?

    self.has_cbk = false
  end
end
