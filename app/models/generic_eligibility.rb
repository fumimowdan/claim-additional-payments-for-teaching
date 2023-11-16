class GenericEligibility < ApplicationRecord
  belongs_to :school
  has_one :claim, as: :eligibility, inverse_of: :eligibility

  def policy
    policy_name.constantize
  end

  def ineligible?
    false
  end

  def current_school
    school
  end

  def award_amount
    return if super.blank?

    BigDecimal(super)
  end

  def ineligible_reason; end
  def submit!; end
end
