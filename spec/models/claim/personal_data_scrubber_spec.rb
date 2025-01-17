require "rails_helper"

RSpec.describe Claim::PersonalDataScrubber, type: :model do
  subject(:personal_data_scrubber) { described_class.new.scrub_completed_claims }

  let(:user) { create(:dfe_signin_user) }
  let!(:policy_configuration) { create(:policy_configuration, :additional_payments) }
  let(:current_academic_year) { AcademicYear.current }
  let(:last_academic_year) { Time.zone.local(current_academic_year.start_year, 8, 1) }

  it "does not delete details from a submitted claim" do
    claim = create(:claim, :submitted, updated_at: last_academic_year)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a submitted but held claim" do
    claim = create(:claim, :submitted, :held, updated_at: last_academic_year)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a claim with an approval, but undone" do
    claim = create(:claim, :submitted, updated_at: last_academic_year)
    create(:decision, :approved, :undone, claim: claim)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from an approved but unpaid claim" do
    claim = create(:claim, :approved, updated_at: last_academic_year)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a newly rejected claim" do
    claim = create(:claim, :rejected)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a newly paid claim" do
    claim = create(:claim, :approved)
    create(:payment, :confirmed, :with_figures, claims: [claim])

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a claim with a rejection which is old but undone" do
    claim = create(:claim, :submitted)
    create(:decision, :rejected, :undone, claim: claim, created_at: last_academic_year)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a claim that has a payment, but has a payrollable topup" do
    lup_eligibility = create(:levelling_up_premium_payments_eligibility, :eligible, award_amount: 1500.0)
    claim = create(:claim, :approved, policy: LevellingUpPremiumPayments, eligibility: lup_eligibility)
    create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
    create(:topup, payment: nil, claim: claim, award_amount: 500, created_by: user)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "does not delete details from a claim that has a payment, but has a payrolled topup without payment confirmation" do
    claim = nil

    travel_to 2.months.ago do
      lup_eligibility = create(:levelling_up_premium_payments_eligibility, :eligible, award_amount: 1500.0)
      claim = create(:claim, :approved, policy: LevellingUpPremiumPayments, eligibility: lup_eligibility)
      create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
    end

    payment2 = create(:payment, :with_figures, claims: [claim], scheduled_payment_date: nil)
    create(:topup, payment: payment2, claim: claim, award_amount: 500, created_by: user)

    expect { personal_data_scrubber }.not_to change { claim.reload.attributes }
  end

  it "deletes expected details from a claim with multiple payments all of which have been confirmed" do
    claim = nil

    travel_to 2.months.ago do
      lup_eligibility = create(:levelling_up_premium_payments_eligibility, :eligible, award_amount: 1500.0)
      claim = create(:claim, :approved, policy: LevellingUpPremiumPayments, eligibility: lup_eligibility)
      create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
    end

    payment2 = create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
    create(:topup, payment: payment2, claim: claim, award_amount: 500, created_by: user)

    expect { personal_data_scrubber }.to change { claim.reload.attributes }
  end

  it "deletes expected details from an old rejected claim, setting a personal_data_removed_at timestamp" do
    freeze_time do
      claim = create(:claim, :submitted)
      create(:decision, :rejected, claim: claim, created_at: last_academic_year)
      claim.update_attribute :hmrc_bank_validation_responses, ["test"]

      personal_data_scrubber
      cleaned_claim = Claim.find(claim.id)

      expect(cleaned_claim.first_name).to be_nil
      expect(cleaned_claim.middle_name).to be_nil
      expect(cleaned_claim.surname).to be_nil
      expect(cleaned_claim.date_of_birth).to be_nil
      expect(cleaned_claim.address_line_1).to be_nil
      expect(cleaned_claim.address_line_2).to be_nil
      expect(cleaned_claim.address_line_3).to be_nil
      expect(cleaned_claim.address_line_4).to be_nil
      expect(cleaned_claim.postcode).to be_nil
      expect(cleaned_claim.payroll_gender).to be_nil
      expect(cleaned_claim.national_insurance_number).to be_nil
      expect(cleaned_claim.bank_sort_code).to be_nil
      expect(cleaned_claim.bank_account_number).to be_nil
      expect(cleaned_claim.building_society_roll_number).to be_nil
      expect(cleaned_claim.banking_name).to be_nil
      expect(cleaned_claim.hmrc_bank_validation_responses).to be_nil
      expect(cleaned_claim.mobile_number).to be_nil
      expect(cleaned_claim.personal_data_removed_at).to eq(Time.zone.now)
    end
  end

  it "deletes expected details from an old paid claim, setting a personal_data_removed_at timestamp" do
    freeze_time do
      claim = create(:claim, :approved)
      create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
      claim.update_attribute :hmrc_bank_validation_responses, ["test"]

      personal_data_scrubber
      cleaned_claim = Claim.find(claim.id)

      expect(cleaned_claim.first_name).to be_nil
      expect(cleaned_claim.middle_name).to be_nil
      expect(cleaned_claim.surname).to be_nil
      expect(cleaned_claim.date_of_birth).to be_nil
      expect(cleaned_claim.address_line_1).to be_nil
      expect(cleaned_claim.address_line_2).to be_nil
      expect(cleaned_claim.address_line_3).to be_nil
      expect(cleaned_claim.address_line_4).to be_nil
      expect(cleaned_claim.postcode).to be_nil
      expect(cleaned_claim.payroll_gender).to be_nil
      expect(cleaned_claim.national_insurance_number).to be_nil
      expect(cleaned_claim.bank_sort_code).to be_nil
      expect(cleaned_claim.bank_account_number).to be_nil
      expect(cleaned_claim.building_society_roll_number).to be_nil
      expect(cleaned_claim.banking_name).to be_nil
      expect(cleaned_claim.hmrc_bank_validation_responses).to be_nil
      expect(cleaned_claim.mobile_number).to be_nil
      expect(cleaned_claim.personal_data_removed_at).to eq(Time.zone.now)
    end
  end

  it "only scrubs claims from the previous academic year" do
    # Initialise the scrubber, and create a claim
    scrubber = Claim::PersonalDataScrubber.new

    claim = create(:claim, :submitted)
    create(:decision, :rejected, claim: claim)

    travel_to(last_academic_year) do
      claim = create(:claim, :submitted)
      create(:decision, :rejected, claim: claim)
    end

    freeze_time do
      scrubber.scrub_completed_claims
      claims = Claim.order(created_at: :asc)
      expect(claims.first.personal_data_removed_at).to eq(Time.zone.now)
      expect(claims.last.personal_data_removed_at).to be_nil
    end
  end

  it "also deletes expected details from the scrubbed claims’ amendments, setting a personal_data_removed_at timestamp on the amendments" do
    claim, amendment = nil
    travel_to last_academic_year - 1.week do
      claim = create(:claim, :submitted)
      amendment = create(:amendment, claim: claim, claim_changes: {
        "teacher_reference_number" => [generate(:teacher_reference_number).to_s, claim.teacher_reference_number],
        "payroll_gender" => ["male", claim.payroll_gender],
        "date_of_birth" => [25.years.ago.to_date, claim.date_of_birth],
        "student_loan_plan" => ["plan_1", claim.student_loan_plan],
        "bank_sort_code" => ["457288", claim.bank_sort_code],
        "bank_account_number" => ["84818482", claim.bank_account_number],
        "building_society_roll_number" => ["123456789/ABCD", claim.building_society_roll_number]
      })
      create(:decision, :approved, claim: claim, created_at: last_academic_year)
      create(:payment, :confirmed, :with_figures, claims: [claim], scheduled_payment_date: last_academic_year)
    end

    freeze_time do
      original_trn_change = amendment.claim_changes["teacher_reference_number"]

      personal_data_scrubber

      cleaned_amendment = Amendment.find(amendment.id)

      expect(cleaned_amendment.claim_changes.keys).to match_array(%w[teacher_reference_number payroll_gender date_of_birth student_loan_plan bank_sort_code bank_account_number building_society_roll_number])
      expect(cleaned_amendment.notes).not_to be_nil
      expect(cleaned_amendment.claim_changes["teacher_reference_number"]).to eq(original_trn_change)
      expect(cleaned_amendment.claim_changes["date_of_birth"]).to eq(nil)
      expect(cleaned_amendment.claim_changes["payroll_gender"]).to eq(nil)
      expect(cleaned_amendment.claim_changes["bank_sort_code"]).to eq(nil)
      expect(cleaned_amendment.claim_changes["bank_account_number"]).to eq(nil)
      expect(cleaned_amendment.claim_changes["building_society_roll_number"]).to eq(nil)

      expect(cleaned_amendment.personal_data_removed_at).to eq(Time.zone.now)
    end
  end
end
