class Topup < ApplicationRecord
  include ActiveSupport::NumberHelper

  belongs_to :claim
  belongs_to :payment, optional: true
  belongs_to :created_by, class_name: "DfeSignIn::User"

  scope :payrollable, -> { includes(:claim).where(payment: nil) }

  validates :award_amount, presence: {message: "Enter top up amount"}
  validate :award_amount_must_be_in_range, on: :create

  delegate :teacher_reference_number, to: :claim

  def payrolled?
    payment.present?
  end

  private

  def award_amount_must_be_in_range
    return unless award_amount.present?

    max = LevellingUpPremiumPayments::Award.where(academic_year: claim.academic_year.to_s).maximum(:award_amount)
    total_amount = claim.award_amount_with_topups + award_amount

    unless total_amount.between?(1, max)
      errors.add(:award_amount, "Enter a positive amount up to #{number_to_currency(max - claim.award_amount_with_topups)} (inclusive)")
    end
  end
end
