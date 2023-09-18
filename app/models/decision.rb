class Decision < ApplicationRecord
  belongs_to :claim
  belongs_to :created_by, class_name: "DfeSignIn::User", optional: true

  # NOTE: remember en.yml -> admin.decision.rejected_reasons
  REJECTED_REASONS = [
    :ineligible_subject,
    :ineligible_year,
    :ineligible_school,
    :ineligible_qualification,
    :no_qts_or_qtls,
    :duplicate,
    :no_response,
    :other
  ]

  store_accessor :rejected_reasons, *REJECTED_REASONS, prefix: true

  # NOTE: Don't store the rejected_reasons data params from the form when Approve is selected
  before_validation :clear_rejected_reasons, unless: :rejected?

  validates :result, presence: {message: "Make a decision to approve or reject the claim"}
  validate :claim_must_be_approvable, if: :approved?, on: :create
  validate :claim_must_be_rejectable, if: :rejected?, on: :create
  validate :claim_must_have_undoable_decision, if: :undone?, on: :update
  validate :rejected_reasons_required, if: -> { !undone? && rejected? }
  validates :notes, if: -> { rejected? && rejected_reasons_other? }, presence: {message: "You must enter a reason for rejecting this claim in the decision note"}
  validates :notes, if: -> { !created_by_id? }, presence: {message: "You must add a note when the decision is automated"}

  scope :active, -> { where(undone: false) }

  enum result: {
    approved: 0,
    rejected: 1
  }

  def readonly?
    return false if destroyed_by_association
    persisted? && !undone
  end

  def number_of_days_since_claim_submitted
    (created_at.to_date - claim.submitted_at.to_date).to_i
  end

  def rejected_reasons_hash
    REJECTED_REASONS.reduce({}) do |memo, reason|
      memo.merge("reason_#{reason}".to_sym => public_send("rejected_reasons_#{reason}".to_sym) || "0")
    end
  end

  private

  def claim_must_be_approvable
    errors.add(:base, "This claim cannot be approved") unless claim.approvable?
  end

  def claim_must_be_rejectable
    errors.add(:base, "This claim cannot be rejected") unless claim.rejectable?
  end

  def claim_must_have_undoable_decision
    errors.add(:base, "This claim cannot have its decision undone") unless claim.decision_undoable?
  end

  # NOTE: as rejected_reasons are stored as JSONB, question mark methods and converting to boolean rails magic isn't available
  def rejected_reasons_other?
    rejected_reasons_other == "1"
  end

  def rejected_reasons_required
    return if rejected_reasons.value?("1")

    errors.add(:rejected_reasons, "At least one reason is required")
  end

  def clear_rejected_reasons
    REJECTED_REASONS.each do |r|
      send("rejected_reasons_#{r}=".to_sym, nil)
    end
  end
end
