require "rails_helper"

RSpec.describe EarlyCareerPayments::SlugSequence do
  let(:claim) { build(:claim, eligibility: build(:early_career_payments_eligibility)) }

  subject(:slug_sequence) { EarlyCareerPayments::SlugSequence.new(claim) }

  describe "The sequence as defined by #slugs" do
    it "excludes the “ineligible” slug if the claim is not actually ineligible" do
      expect(claim.eligibility).not_to be_ineligible
      expect(slug_sequence.slugs).not_to include("ineligible")

      claim.eligibility.nqt_in_academic_year_after_itt = false
      expect(claim.eligibility).to be_ineligible
      expect(slug_sequence.slugs).to include("ineligible")
    end

    it "excludes the 'entire-term-contract' slug if the claimant is not a supply teacher" do
      claim.eligibility.employed_as_supply_teacher = false

      expect(slug_sequence.slugs).not_to include("entire-term-contract")
    end
  end

  it "excludes the 'employed-directly' slug if the claimant is not a supply teacher" do
    claim.eligibility.employed_as_supply_teacher = false

    expect(slug_sequence.slugs).not_to include("employed-directly")
  end
end