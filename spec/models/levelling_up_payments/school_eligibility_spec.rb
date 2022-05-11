require "rails_helper"

RSpec.describe LevellingUpPayments::SchoolEligibility do
  let(:eligible_school) { build(:school, :levelling_up_payments_eligible) }
  let(:ineligible_school) { build(:school, :levelling_up_payments_ineligible) }
  let(:not_found) { build(:school, :not_found_in_levelling_up_payments_spreadsheet) }

  describe ".new" do
    specify { expect { described_class.new(nil) }.to raise_error("nil school") }
  end

  describe "#eligible?" do
    context "eligible" do
      specify { expect(described_class.new(eligible_school)).to be_eligible }
    end

    context "ineligible" do
      specify { expect(described_class.new(ineligible_school)).to_not be_eligible }
    end

    context "not found" do
      specify { expect(described_class.new(not_found)).to_not be_eligible }
    end
  end
end
